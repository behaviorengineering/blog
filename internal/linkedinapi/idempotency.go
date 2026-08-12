package linkedinapi

import (
	"regexp"
	"strings"
)

var urlRe = regexp.MustCompile(`https://behaviorengineering\.ai/[^\s)]+`)

// ExtractSiteURLs returns all behaviorengineering.ai URLs found in text (in order).
func ExtractSiteURLs(text string) []string {
	m := urlRe.FindAllString(text, -1)
	var out []string
	seen := map[string]struct{}{}
	for _, u := range m {
		u = strings.TrimRight(u, ".,;\"'")
		if _, ok := seen[u]; ok {
			continue
		}
		seen[u] = struct{}{}
		out = append(out, u)
	}
	return out
}

// PickCanonicalURL prefers an English (non-/es/) URL if present, else first URL.
func PickCanonicalURL(urls []string) string {
	for _, u := range urls {
		if strings.Contains(u, "://behaviorengineering.ai/es/") {
			continue
		}
		return u
	}
	if len(urls) > 0 {
		return urls[0]
	}
	return ""
}

