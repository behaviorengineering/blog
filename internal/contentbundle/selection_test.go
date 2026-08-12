package contentbundle

import "testing"

func TestNormalizeBundleRel(t *testing.T) {
	cases := []struct {
		in, want string
	}{
		{"human-condition/2026-05-01-ego-as-game", "human-condition/2026-05-01-ego-as-game"},
		{"/content/human-condition/2026-05-01-ego-as-game/", "human-condition/2026-05-01-ego-as-game"},
	}
	for _, tc := range cases {
		if got := normalizeBundleRel(tc.in); got != tc.want {
			t.Fatalf("normalizeBundleRel(%q) = %q want %q", tc.in, got, tc.want)
		}
	}
}
