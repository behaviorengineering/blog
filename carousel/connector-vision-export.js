import { buildBackgroundPanoramaContext, paintPanoramicStripBackground, parseBackgroundWaveConfig } from './background-panorama.js';
import { wavePaletteFromTheme, resolveColor } from './theme.js';
import {
  buildMotifStripContext,
  loadMotifStripImage,
  paintPanoramicMotifStrip,
  parseMotifStripConfig,
} from './motif-strip.js';
import { downloadCanvasWebp, exportFilename, exportStripFilename } from './export.js';
import { renderSlideToCanvas } from './renderer.js';

/** Playwright / vision LLM target for strip screenshots. */
export const VISION_STRIP_CANVAS_ID = 'carousel-vision-strip';
export const VISION_STRIP_PANEL_ID = 'carousel-vision-strip-panel';

import {
  PANORAMA_GAP_PX,
  PANORAMA_SLIDE_WIDTH_PX,
  stripSlideGapPx,
} from './slide-constants.js';

export { PANORAMA_GAP_PX, PANORAMA_SLIDE_WIDTH_PX, stripSlideGapPx };

/** @deprecated Use {@link stripSlideGapPx} */
export const panoramaExportGapPx = stripSlideGapPx;

/**
 * @typedef {Object} VisionStripDeck
 * @property {string} [slug]
 * @property {Partial<import('./theme.js').DeckTheme>} [deck]
 * @property {Array<{ number: number, role?: string, variants: import('./renderer.js').SlideVariant[] }>} slides
 */

/**
 * @param {VisionStripDeck} deck
 * @param {import('./theme.js').DeckTheme} theme
 * @param {(live: import('./theme.js').DeckTheme) => Partial<import('./theme.js').DeckTheme> & Record<string, unknown>} renderOverrides
 * @param {import('./renderer.js').RenderOptions} renderContext
 * @param {number} [slideWidth] px per slide (default 540 for vision review)
 * @param {{ includedSlideNumbers?: Set<number>|number[], variantIndexFor?: (slideNumber: number) => number, showSlideLabels?: boolean, gap?: number }} [options]
 */
export async function buildVisionStripCanvas(
  deck,
  theme,
  renderOverrides,
  renderContext,
  slideWidth = 540,
  options = {},
) {
  const includedSet = options.includedSlideNumbers instanceof Set
    ? options.includedSlideNumbers
    : Array.isArray(options.includedSlideNumbers)
      ? new Set(options.includedSlideNumbers)
      : null;
  const showSlideLabels = options.showSlideLabels !== false;
  const gap = Number.isFinite(options.gap) ? Math.max(0, options.gap) : stripSlideGapPx(slideWidth);
  const slides = Array.isArray(deck.slides) ? deck.slides : [];
  if (slides.length === 0) throw new Error('Deck has no slides');

  /** @type {HTMLCanvasElement[]} */
  const frames = [];
  /** @type {number[]} */
  const slideNumbers = [];

  for (const slide of slides) {
    if (includedSet && !includedSet.has(slide.number)) continue;
    const variantIndex = typeof options.variantIndexFor === 'function'
      ? options.variantIndexFor(slide.number)
      : 0;
    const variant = slide.variants?.[variantIndex] ?? slide.variants?.[0];
    if (!variant) continue;
    const role = (slide.role || '').trim().toLowerCase();
    const canvas = await renderSlideToCanvas(variant, renderOverrides(theme), {
      ...renderContext,
      slideRole: role,
      supersample: 2,
      outputSize: slideWidth,
      backgroundPanoramaContext: role === 'post_cta'
        ? undefined
        : buildBackgroundPanoramaContext(deck, slide.number) ?? undefined,
      motifStripContext: role === 'post_cta'
        ? undefined
        : buildMotifStripContext(deck, slide.number) ?? undefined,
      skipBackground: role !== 'post_cta',
      skipMotifStrip: role !== 'post_cta',
      grain: false,
      studioPreview: true,
    });
    frames.push(canvas);
    slideNumbers.push(slide.number);
  }

  if (frames.length === 0) {
    throw new Error('No slides selected for vision strip. Enable In strip on at least one slide.');
  }

  const frameHeight = Math.max(...frames.map((frame) => frame.height));
  const stripWidth = frames.reduce(
    (sum, frame, index) => sum + frame.width + (index > 0 ? gap : 0),
    0,
  );
  const strip = document.createElement('canvas');
  strip.width = stripWidth;
  strip.height = frameHeight;
  strip.dataset.frameCount = String(frames.length);
  strip.id = VISION_STRIP_CANVAS_ID;
  strip.setAttribute('data-testid', VISION_STRIP_CANVAS_ID);
  strip.setAttribute('aria-label', 'Carousel vision strip preview');

  const ctx = strip.getContext('2d');
  if (!ctx) throw new Error('Canvas 2D context unavailable');

  ctx.imageSmoothingEnabled = true;
  ctx.imageSmoothingQuality = 'high';
  ctx.fillStyle = '#111418';
  ctx.fillRect(0, 0, stripWidth, frameHeight);

  const mergedTheme = renderOverrides(theme);
  const waveConfig = parseBackgroundWaveConfig(mergedTheme);
  const frameWidth = frames[0]?.width ?? slideWidth;
  const deckSlideCount = slides.length;
  const slotSlideIndices = slideNumbers.map(
    (slideNumber) => slides.findIndex((entry) => entry.number === slideNumber),
  );
  paintPanoramicStripBackground(
    ctx,
    frameWidth,
    frameHeight,
    deckSlideCount,
    wavePaletteFromTheme(theme),
    waveConfig,
    { gap, slotSlideIndices },
  );

  const motifConfig = parseMotifStripConfig(
    /** @type {Record<string, unknown>} */ (deck.deck)?.motifStrip,
  );
  if (motifConfig) {
    try {
      const motifImage = await loadMotifStripImage(
        motifConfig,
        renderContext.assetBaseUrl ?? '',
        (token) => resolveColor(mergedTheme, token),
      );
      const slideRoles = slideNumbers.map((slideNumber) => {
        const slide = slides.find((entry) => entry.number === slideNumber);
        return (slide?.role || '').trim().toLowerCase();
      });
      paintPanoramicMotifStrip(
        ctx,
        frameWidth,
        frameHeight,
        deckSlideCount,
        motifConfig,
        motifImage,
        mergedTheme,
        { gap, slotSlideIndices, slideRoles },
      );
    } catch (error) {
      console.warn('[carousel] Panoramic motif strip failed:', error);
    }
  }

  /** @type {Array<{ slideNumber: number, x: number, width: number }>} */
  const frameLayout = [];

  let x = 0;
  for (let i = 0; i < frames.length; i += 1) {
    const frame = frames[i];
    frameLayout.push({ slideNumber: slideNumbers[i], x, width: frame.width });
    ctx.drawImage(frame, x, 0);
    if (showSlideLabels) {
      ctx.fillStyle = 'rgba(245, 245, 240, 0.92)';
      ctx.font = `600 ${Math.max(11, Math.round(frame.height * 0.028))}px ${theme.bodyFont || 'sans-serif'}, sans-serif`;
      ctx.textAlign = 'left';
      ctx.textBaseline = 'top';
      ctx.fillText(`Slide ${slideNumbers[i]}`, x + 8, 8);
    }
    x += frame.width + gap;
  }
  strip.dataset.frameLayout = JSON.stringify(frameLayout);

  return strip;
}

/** @deprecated Use {@link buildVisionStripCanvas} */
export const buildConnectorVisionStripCanvas = buildVisionStripCanvas;

/**
 * Downscale strip bitmap with canvas filtering (avoids CSS transform moiré on gradients).
 * @param {HTMLCanvasElement} strip
 * @param {number} scale
 * @returns {HTMLCanvasElement}
 */
function resampleStripCanvas(strip, scale) {
  const factor = Number.isFinite(scale) && scale > 0 ? scale : 1;
  if (factor >= 0.999) return strip;

  const outW = Math.max(1, Math.round(strip.width * factor));
  const outH = Math.max(1, Math.round(strip.height * factor));
  const out = document.createElement('canvas');
  out.width = outW;
  out.height = outH;
  out.id = strip.id;
  out.setAttribute('data-testid', strip.getAttribute('data-testid') || VISION_STRIP_CANVAS_ID);
  out.setAttribute('aria-label', strip.getAttribute('aria-label') || 'Carousel vision strip preview');
  if (strip.dataset.frameCount) out.dataset.frameCount = strip.dataset.frameCount;

  const layout = parseStripFrameLayout(strip);
  if (layout.length > 0) {
    out.dataset.frameLayout = JSON.stringify(layout.map((entry) => ({
      slideNumber: entry.slideNumber,
      x: Math.round(entry.x * factor),
      width: Math.round(entry.width * factor),
    })));
  }

  const ctx = out.getContext('2d');
  if (!ctx) throw new Error('Canvas 2D context unavailable');
  ctx.imageSmoothingEnabled = true;
  ctx.imageSmoothingQuality = 'high';
  ctx.drawImage(strip, 0, 0, strip.width, strip.height, 0, 0, outW, outH);
  return out;
}

/**
 * @param {HTMLCanvasElement} strip
 * @param {HTMLElement} container
 */
export function mountVisionStripCanvas(strip, container) {
  container.innerHTML = '';
  strip.id = VISION_STRIP_CANVAS_ID;
  strip.setAttribute('data-testid', VISION_STRIP_CANVAS_ID);
  strip.setAttribute('aria-label', 'Carousel vision strip preview');
  strip.style.transform = '';
  strip.style.transformOrigin = '';
  strip.style.width = '';
  strip.style.height = '';
  strip.className = '';
  container.appendChild(strip);
  container.hidden = false;
}

/**
 * @param {HTMLCanvasElement} strip
 * @returns {Array<{ slideNumber: number, x: number, width: number }>}
 */
function parseStripFrameLayout(strip) {
  try {
    const raw = strip.dataset.frameLayout;
    if (!raw) return [];
    const parsed = JSON.parse(raw);
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    return [];
  }
}

/**
 * Keep strip mount scroll after rebuild: focus a slide or restore prior scrollLeft.
 * @param {HTMLElement} mount
 * @param {HTMLCanvasElement} strip
 * @param {{ displayScale?: number, focusSlideNumber?: number|null, scrollLeft?: number }} [options]
 */
export function restoreVisionStripScroll(mount, strip, options = {}) {
  if (!(mount instanceof HTMLElement) || !(strip instanceof HTMLCanvasElement)) return;

  const mounted = mount.querySelector(`#${VISION_STRIP_CANVAS_ID}`);
  const contentWidth = mounted instanceof HTMLCanvasElement
    ? mounted.width
    : strip.width;
  const maxScroll = Math.max(0, contentWidth - mount.clientWidth);

  const focusSlideNumber = options.focusSlideNumber;
  if (focusSlideNumber != null) {
    const layoutSource = mounted instanceof HTMLCanvasElement ? mounted : strip;
    const frame = parseStripFrameLayout(layoutSource).find((entry) => entry.slideNumber === focusSlideNumber);
    if (frame) {
      const centered = frame.x - Math.max(0, (mount.clientWidth - frame.width) / 2);
      mount.scrollLeft = Math.max(0, Math.min(centered, maxScroll));
      return;
    }
  }

  if (typeof options.scrollLeft === 'number' && Number.isFinite(options.scrollLeft)) {
    mount.scrollLeft = Math.max(0, Math.min(options.scrollLeft, maxScroll));
  }
}

/**
 * @param {VisionStripDeck} deck
 * @param {import('./theme.js').DeckTheme} theme
 * @param {(live: import('./theme.js').DeckTheme) => Partial<import('./theme.js').DeckTheme> & Record<string, unknown>} renderOverrides
 * @param {import('./renderer.js').RenderOptions} renderContext
 * @param {HTMLElement} container
 * @param {number} [slideWidth]
 * @param {{ displayScale?: number, resolveDisplayScale?: (strip: HTMLCanvasElement, mount: HTMLElement) => number, includedSlideNumbers?: Set<number>|number[], variantIndexFor?: (slideNumber: number) => number }} [options]
 */
export async function buildAndMountVisionStrip(
  deck,
  theme,
  renderOverrides,
  renderContext,
  container,
  slideWidth = 540,
  options = {},
) {
  const strip = await buildVisionStripCanvas(
    deck,
    theme,
    renderOverrides,
    renderContext,
    slideWidth,
    options,
  );
  const displayScale = typeof options.resolveDisplayScale === 'function'
    ? options.resolveDisplayScale(strip, container)
    : (options.displayScale ?? 1);
  const displayStrip = resampleStripCanvas(strip, displayScale);
  mountVisionStripCanvas(displayStrip, container);
  return displayStrip;
}

/**
 * @param {VisionStripDeck} deck
 * @param {import('./theme.js').DeckTheme} theme
 * @param {(live: import('./theme.js').DeckTheme) => Partial<import('./theme.js').DeckTheme> & Record<string, unknown>} renderOverrides
 * @param {import('./renderer.js').RenderOptions} renderContext
 * @param {number} [slideWidth]
 * @param {{ showSlideLabels?: boolean, gap?: number, filename?: string, includedSlideNumbers?: Set<number>|number[], variantIndexFor?: (slideNumber: number) => number }} [options]
 */
export async function exportPanoramicStrip(
  deck,
  theme,
  renderOverrides,
  renderContext,
  slideWidth = 540,
  options = {},
) {
  const slug = deck.slug || 'carousel';
  const strip = await buildVisionStripCanvas(
    deck,
    theme,
    renderOverrides,
    renderContext,
    slideWidth,
    {
      ...options,
      showSlideLabels: options.showSlideLabels ?? false,
      gap: options.gap ?? stripSlideGapPx(slideWidth),
    },
  );
  downloadCanvasWebp(strip, options.filename ?? exportStripFilename(slug));
  return strip;
}

/** @deprecated Use {@link exportPanoramicStrip} */
export async function exportConnectorVisionStrip(
  deck,
  theme,
  renderOverrides,
  renderContext,
  slideWidth = 540,
  options = {},
) {
  const slug = deck.slug || 'carousel';
  return exportPanoramicStrip(deck, theme, renderOverrides, renderContext, slideWidth, {
    ...options,
    filename: options.filename ?? `${slug}-vision-strip.webp`,
  });
}

/** Delay between sequential browser downloads so each file is not blocked. */
const SEPARATED_DOWNLOAD_GAP_MS = 200;

/**
 * @param {VisionStripDeck} deck
 * @param {import('./theme.js').DeckTheme} theme
 * @param {(live: import('./theme.js').DeckTheme) => Partial<import('./theme.js').DeckTheme> & Record<string, unknown>} renderOverrides
 * @param {import('./renderer.js').RenderOptions} renderContext
 * @param {{ includedSlideNumbers?: Set<number>|number[], variantIndexFor?: (slideNumber: number) => number, downloadGapMs?: number }} [options]
 * @returns {Promise<number>} Number of files downloaded
 */
export async function exportSeparatedSlides(
  deck,
  theme,
  renderOverrides,
  renderContext,
  options = {},
) {
  const includedSet = options.includedSlideNumbers instanceof Set
    ? options.includedSlideNumbers
    : Array.isArray(options.includedSlideNumbers)
      ? new Set(options.includedSlideNumbers)
      : null;
  const slides = Array.isArray(deck.slides) ? deck.slides : [];
  if (slides.length === 0) throw new Error('Deck has no slides');

  const slug = deck.slug || 'carousel';
  const mergedTheme = renderOverrides(theme);
  const downloadGapMs = Number.isFinite(options.downloadGapMs)
    ? Math.max(0, options.downloadGapMs)
    : SEPARATED_DOWNLOAD_GAP_MS;
  let count = 0;

  for (const slide of slides) {
    if (includedSet && !includedSet.has(slide.number)) continue;
    const variantIndex = typeof options.variantIndexFor === 'function'
      ? options.variantIndexFor(slide.number)
      : 0;
    const variant = slide.variants?.[variantIndex] ?? slide.variants?.[0];
    if (!variant) continue;

    const role = (slide.role || '').trim().toLowerCase();
    const canvas = await renderSlideToCanvas(variant, mergedTheme, {
      ...renderContext,
      slideRole: role,
      supersample: 2,
      backgroundPanoramaContext: role === 'post_cta'
        ? undefined
        : buildBackgroundPanoramaContext(deck, slide.number) ?? undefined,
      motifStripContext: role === 'post_cta'
        ? undefined
        : buildMotifStripContext(deck, slide.number) ?? undefined,
      skipBackground: role !== 'post_cta',
      grain: false,
    });
    await downloadCanvasWebp(canvas, exportFilename(slug, slide.number, variantIndex));
    count += 1;
    if (downloadGapMs > 0) {
      await new Promise((resolve) => window.setTimeout(resolve, downloadGapMs));
    }
  }

  if (count === 0) {
    throw new Error('No slides selected for export. Enable In strip on at least one slide.');
  }

  return count;
}

/**
 * @param {HTMLElement} container
 */
export function showVisionStripPlaceholder(container, message = 'Building vision strip…') {
  container.innerHTML = '';
  container.hidden = false;
  const note = document.createElement('p');
  note.className = 'carousel-vision-strip-placeholder';
  note.textContent = message;
  container.appendChild(note);
}

/**
 * @param {VisionStripDeck} deck
 * @param {import('./theme.js').DeckTheme} theme
 * @param {(live: import('./theme.js').DeckTheme) => Partial<import('./theme.js').DeckTheme> & Record<string, unknown>} renderOverrides
 * @param {import('./renderer.js').RenderOptions} renderContext
 * @param {HTMLElement} container
 * @param {() => { includedSlideNumbers?: Set<number>, variantIndexFor?: (slideNumber: number) => number }} [getStudioOptions]
 */
export function installVisionStripController(
  deck,
  theme,
  renderOverrides,
  renderContext,
  container,
  getStudioOptions = () => ({}),
) {
  /** @type {HTMLCanvasElement|null} */
  let lastStrip = null;

  /** @param {number} [slideWidth] @param {Record<string, unknown>} [options] */
  async function buildStrip(slideWidth = 540, options = {}) {
    const studioOptions = getStudioOptions();
    const mergedOptions = {
      ...options,
      includedSlideNumbers: studioOptions.includedSlideNumbers,
      variantIndexFor: studioOptions.variantIndexFor,
    };
    lastStrip = await buildAndMountVisionStrip(
      deck,
      theme,
      renderOverrides,
      renderContext,
      container,
      slideWidth,
      mergedOptions,
    );
    return lastStrip;
  }

  const api = {
    selector: `#${VISION_STRIP_CANVAS_ID}`,
    panelSelector: `#${VISION_STRIP_PANEL_ID}`,
    /**
     * @param {number} [slideWidth]
     * @param {Record<string, unknown>} [options]
     */
    async build(slideWidth = 540, options = {}) {
      return buildStrip(slideWidth, options);
    },
    getCanvas() {
      return lastStrip ?? document.getElementById(VISION_STRIP_CANVAS_ID);
    },
    /**
     * @param {{ slideWidth?: number, showSlideLabels?: boolean, gap?: number, filename?: string }} [options]
     */
    async download(options = {}) {
      const studioOptions = getStudioOptions();
      const slideWidth = options.slideWidth ?? theme.size ?? 1080;
      const mergedOptions = {
        ...options,
        includedSlideNumbers: studioOptions.includedSlideNumbers,
        variantIndexFor: studioOptions.variantIndexFor,
        showSlideLabels: options.showSlideLabels ?? false,
        gap: options.gap ?? stripSlideGapPx(slideWidth),
      };
      return exportPanoramicStrip(
        deck,
        theme,
        renderOverrides,
        renderContext,
        slideWidth,
        mergedOptions,
      );
    },
    /**
     * @param {{ downloadGapMs?: number }} [options]
     * @returns {Promise<number>}
     */
    async downloadAll(options = {}) {
      const studioOptions = getStudioOptions();
      const mergedOptions = {
        ...options,
        includedSlideNumbers: studioOptions.includedSlideNumbers,
        variantIndexFor: studioOptions.variantIndexFor,
      };
      return exportSeparatedSlides(
        deck,
        theme,
        renderOverrides,
        renderContext,
        mergedOptions,
      );
    },
  };

  /** @type {Window & { carouselVisionStrip?: typeof api }} */
  const win = window;
  win.carouselVisionStrip = api;
  return api;
}
