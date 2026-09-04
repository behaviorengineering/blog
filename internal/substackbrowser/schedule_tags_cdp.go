package substackbrowser

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"strings"
	"time"

	"github.com/chromedp/cdproto/input"
	"github.com/chromedp/chromedp"
)

// tagPointResult is the JSON shape returned by tag-combobox locate helpers.
type tagPointResult struct {
	OK       bool    `json:"ok"`
	Already  bool    `json:"already"`
	X        float64 `json:"x"`
	Y        float64 `json:"y"`
	Reason   string  `json:"reason"`
	QueryOK  bool    `json:"queryOk"`
	OptionOK bool    `json:"optionOk"`
}

// AddPublishTagsCDP types each tag into Substack's Headless UI combobox and selects the
// matching option with a trusted CDP mouse click (JS el.click is ignored by Headless UI).
func AddPublishTagsCDP(ctx context.Context, tags []string) error {
	clean := make([]string, 0, len(tags))
	for _, t := range tags {
		t = strings.TrimSpace(t)
		if t != "" {
			clean = append(clean, t)
		}
	}
	if len(clean) == 0 {
		return nil
	}
	for _, tag := range clean {
		if err := addOnePublishTagCDP(ctx, tag); err != nil {
			return err
		}
	}
	return nil
}

func addOnePublishTagCDP(ctx context.Context, tag string) error {
	var pill tagPointResult
	if err := evalTagJSON(ctx, tagPillStatusJS(tag), &pill); err != nil {
		return fmt.Errorf("substackbrowser: tag pill check for %q: %w", tag, err)
	}
	if pill.Already {
		return nil
	}

	var inp tagPointResult
	if err := evalTagJSON(ctx, tagInputCenterJS(), &inp); err != nil {
		return fmt.Errorf("substackbrowser: tag input locate for %q: %w", tag, err)
	}
	if !inp.OK {
		return fmt.Errorf("substackbrowser: tag input not found for %q: %s", tag, inp.Reason)
	}
	if err := chromedp.Run(ctx,
		chromedp.MouseEvent(input.MouseMoved, inp.X, inp.Y),
		chromedp.MouseClickXY(inp.X, inp.Y),
		chromedp.Sleep(80*time.Millisecond),
	); err != nil {
		return fmt.Errorf("substackbrowser: focus tag input for %q: %w", tag, err)
	}

	var cleared tagPointResult
	if err := evalTagJSON(ctx, tagClearQueryJS(), &cleared); err != nil {
		return fmt.Errorf("substackbrowser: clear tag query for %q: %w", tag, err)
	}
	if !cleared.OK {
		return fmt.Errorf("substackbrowser: clear tag query for %q: %s", tag, cleared.Reason)
	}

	if err := chromedp.Run(ctx,
		chromedp.KeyEvent(tag),
		chromedp.Sleep(350*time.Millisecond),
	); err != nil {
		return fmt.Errorf("substackbrowser: type tag %q: %w", tag, err)
	}

	var opt tagPointResult
	deadline := time.Now().Add(4 * time.Second)
	for {
		if err := evalTagJSON(ctx, tagOptionCenterJS(tag), &opt); err != nil {
			return fmt.Errorf("substackbrowser: tag option locate for %q: %w", tag, err)
		}
		if opt.Already {
			return nil
		}
		if opt.OK {
			break
		}
		if time.Now().After(deadline) {
			return fmt.Errorf("substackbrowser: tag option not found for %q: %s", tag, opt.Reason)
		}
		if err := chromedp.Run(ctx, chromedp.Sleep(120*time.Millisecond)); err != nil {
			return err
		}
	}

	if err := chromedp.Run(ctx,
		chromedp.MouseEvent(input.MouseMoved, opt.X, opt.Y),
		chromedp.Sleep(40*time.Millisecond),
		chromedp.MouseClickXY(opt.X, opt.Y),
		chromedp.Sleep(280*time.Millisecond),
	); err != nil {
		return fmt.Errorf("substackbrowser: click tag option for %q: %w", tag, err)
	}

	if err := evalTagJSON(ctx, tagPillStatusJS(tag), &pill); err != nil {
		return fmt.Errorf("substackbrowser: tag pill recheck for %q: %w", tag, err)
	}
	if pill.Already {
		return nil
	}

	// Fallback: trusted Enter on the focused combobox after the option is highlighted.
	if err := chromedp.Run(ctx,
		chromedp.KeyEvent("\r"),
		chromedp.Sleep(280*time.Millisecond),
	); err != nil {
		return fmt.Errorf("substackbrowser: Enter after tag option for %q: %w", tag, err)
	}
	if err := evalTagJSON(ctx, tagPillStatusJS(tag), &pill); err != nil {
		return fmt.Errorf("substackbrowser: tag pill after Enter for %q: %w", tag, err)
	}
	if pill.Already {
		return nil
	}
	return fmt.Errorf("substackbrowser: tag chip not confirmed after CDP click for %q", tag)
}

func evalTagJSON(ctx context.Context, js string, out *tagPointResult) error {
	var raw string
	if err := chromedp.Run(ctx, chromedp.Evaluate(js, &raw, awaitPromiseEvaluate)); err != nil {
		return err
	}
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return fmt.Errorf("empty evaluate result")
	}
	if err := json.Unmarshal([]byte(raw), out); err != nil {
		return fmt.Errorf("parse %q: %w", truncateForErr(raw, 160), err)
	}
	return nil
}

func truncateForErr(s string, n int) string {
	if len(s) <= n {
		return s
	}
	return s[:n] + "…"
}

func jsonStringLiteral(s string) string {
	b, err := json.Marshal(s)
	if err != nil {
		return `""`
	}
	return string(b)
}

func tagSharedHelpersJS() string {
	return `
  function visible(el) {
    if (!el) return false;
    const r = el.getBoundingClientRect();
    return r.width > 0 && r.height > 0;
  }
  function alnumKey(s) {
    return String(s || '').toLowerCase().replace(/[^a-z0-9]/g, '');
  }
  function cleanTagRowText(s) {
    return String(s || '').split('\n')[0].trim();
  }
  function publishModalRoot() {
    const dialogs = Array.from(document.querySelectorAll('[role="dialog"]')).filter(visible);
    let best = null;
    let bestScore = -1;
    for (const d of dialogs) {
      const txt = (d.innerText || '').toLowerCase();
      const looks =
        txt.includes('add tags') ||
        txt.includes('this post belongs') ||
        txt.includes('delivery') ||
        (txt.includes('scheduling') && txt.includes('email'));
      if (!looks) continue;
      let score = 0;
      if (txt.includes('this post belongs')) score += 3;
      if (txt.includes('add tags')) score += 2;
      if (txt.includes('delivery')) score += 2;
      if (txt.includes('publish')) score += 1;
      if (score > bestScore) {
        bestScore = score;
        best = d;
      }
    }
    return best;
  }
  function isHeadlessTagComboboxInput(inp) {
    if (!inp || inp.tagName !== 'INPUT') return false;
    if ((inp.getAttribute('role') || '').toLowerCase() !== 'combobox') return false;
    const par = inp.parentElement;
    if (!par) return false;
    const cls = String(par.className || '');
    return cls.indexOf('inputBox') >= 0 || cls.indexOf('hasChips') >= 0;
  }
  function isLikelyTagChipButton(el) {
    if (!el || el.tagName !== 'BUTTON') return false;
    if ((el.getAttribute('aria-haspopup') || '').toLowerCase() === 'listbox') return false;
    const id = String(el.id || '');
    if (id.indexOf('headlessui-combobox-button') >= 0) return false;
    if (el.closest('[role="listbox"]')) return false;
    const cls = String(el.className || '');
    if (cls.indexOf('chip') >= 0) return true;
    const par = el.parentElement;
    if (par) {
      const pc = String(par.className || '');
      if (pc.indexOf('hasChips') >= 0 || pc.indexOf('inputBox') >= 0) return true;
    }
    return false;
  }
  function hasCommittedTagPill(tagText) {
    const want = alnumKey(tagText);
    if (!want || want.length < 2) return false;
    const modal = publishModalRoot() || document;
    const chips = Array.from(modal.querySelectorAll('button.chip-lJKwY5, button[class*="chip"], button')).filter(visible);
    for (const el of chips) {
      if (!isLikelyTagChipButton(el) && String(el.className || '').indexOf('chip') < 0) continue;
      const raw = (el.innerText || '').trim();
      if (raw.length < 2 || raw.length > 80) continue;
      if (alnumKey(raw) === want) return true;
    }
    return false;
  }
  function tagInputEl() {
    const roots = [];
    const dlg = publishModalRoot();
    if (dlg) roots.push(dlg);
    roots.push(document);
    for (const root of roots) {
      if (!root || !root.querySelectorAll) continue;
      for (const inp of root.querySelectorAll('input[role="combobox"]')) {
        if (!isHeadlessTagComboboxInput(inp)) continue;
        if (visible(inp) || document.activeElement === inp) return inp;
      }
      for (const inp of root.querySelectorAll('input')) {
        const ph = (inp.getAttribute('placeholder') || '').toLowerCase();
        const al = (inp.getAttribute('aria-label') || '').toLowerCase();
        const id = String(inp.id || '');
        const looks =
          ph.includes('tag') ||
          (ph.includes('select') && ph.includes('create')) ||
          al.includes('tag') ||
          id.indexOf('headlessui-combobox-input') >= 0;
        if (!looks) continue;
        if (visible(inp) || document.activeElement === inp) return inp;
      }
    }
    return null;
  }
  function centerOf(el) {
    if (!el || !el.getBoundingClientRect) return null;
    try { el.scrollIntoView({ block: 'center', inline: 'nearest' }); } catch (e) {}
    const r = el.getBoundingClientRect();
    if (r.width < 2 || r.height < 2) return null;
    return { x: r.left + r.width / 2, y: r.top + r.height / 2 };
  }
  function findExactTagOption(tagText) {
    const needle = String(tagText || '').trim().toLowerCase();
    const want = alnumKey(tagText);
    if (!needle || want.length < 2) return null;
    const rows = Array.from(document.querySelectorAll(
      '[role="listbox"] [role="option"], li[role="option"], [cmdk-item], [data-radix-collection-item]'
    ));
    let best = null;
    let bestLen = 1e9;
    for (const el of rows) {
      if (!visible(el)) continue;
      const line = cleanTagRowText(el.innerText || '').toLowerCase();
      if (!line || line.startsWith('create')) continue;
      if (line === needle || alnumKey(line) === want) {
        if (line.length < bestLen) {
          best = el;
          bestLen = line.length;
        }
      }
    }
    return best;
  }
`
}

func tagPillStatusJS(tag string) string {
	t := jsonStringLiteral(tag)
	return `(async function(){
` + tagSharedHelpersJS() + `
  const tag = ` + t + `;
  if (hasCommittedTagPill(tag)) {
    return JSON.stringify({ ok: true, already: true, x: 0, y: 0, reason: '' });
  }
  return JSON.stringify({ ok: true, already: false, x: 0, y: 0, reason: '' });
})()`
}

func tagInputCenterJS() string {
	return `(async function(){
` + tagSharedHelpersJS() + `
  const inp = tagInputEl();
  if (!inp) {
    return JSON.stringify({ ok: false, already: false, x: 0, y: 0, reason: 'tag combobox input not found' });
  }
  const c = centerOf(inp);
  if (!c) {
    return JSON.stringify({ ok: false, already: false, x: 0, y: 0, reason: 'tag input has no clickable box' });
  }
  try { inp.focus(); } catch (e) {}
  return JSON.stringify({ ok: true, already: false, x: c.x, y: c.y, reason: '' });
})()`
}

func tagClearQueryJS() string {
	return `(async function(){
` + tagSharedHelpersJS() + `
  const inp = tagInputEl();
  if (!inp) {
    return JSON.stringify({ ok: false, already: false, x: 0, y: 0, reason: 'tag combobox input not found' });
  }
  try { inp.focus(); } catch (e) {}
  try { inp.select(); } catch (e) {}
  try {
    const proto = window.HTMLInputElement.prototype;
    const desc = Object.getOwnPropertyDescriptor(proto, 'value');
    if (desc && desc.set) desc.set.call(inp, '');
    else inp.value = '';
  } catch (e) {
    try { inp.value = ''; } catch (e2) {}
  }
  try {
    inp.dispatchEvent(new InputEvent('input', { bubbles: true, cancelable: true, data: '', inputType: 'deleteContentBackward' }));
  } catch (e) {
    inp.dispatchEvent(new Event('input', { bubbles: true }));
  }
  try { document.execCommand('selectAll', false, null); document.execCommand('delete', false, null); } catch (e) {}
  return JSON.stringify({ ok: true, already: false, x: 0, y: 0, reason: '' });
})()`
}

func tagOptionCenterJS(tag string) string {
	t := jsonStringLiteral(tag)
	return `(async function(){
` + tagSharedHelpersJS() + `
  const tag = ` + t + `;
  if (hasCommittedTagPill(tag)) {
    return JSON.stringify({ ok: true, already: true, x: 0, y: 0, reason: '', optionOk: true });
  }
  const el = findExactTagOption(tag);
  if (!el) {
    return JSON.stringify({ ok: false, already: false, x: 0, y: 0, reason: 'exact listbox option not visible', optionOk: false });
  }
  const c = centerOf(el);
  if (!c) {
    return JSON.stringify({ ok: false, already: false, x: 0, y: 0, reason: 'option has no clickable box', optionOk: false });
  }
  return JSON.stringify({ ok: true, already: false, x: c.x, y: c.y, reason: '', optionOk: true });
})()`
}

// LogTagCDPStart logs one line before CDP tag selection (kept thin for operators).
func LogTagCDPStart(n int) {
	log.Printf("substackbrowser: selecting %d publish tag(s) via CDP mouse click (Headless UI)", n)
}
