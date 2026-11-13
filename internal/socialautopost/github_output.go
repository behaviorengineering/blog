package socialautopost

import (
	"fmt"
	"os"
	"strings"
)

// WriteGitHubOutput appends key=value to GITHUB_OUTPUT when that env is set.
// No-op when GITHUB_OUTPUT is empty.
func WriteGitHubOutput(key, value string) error {
	path := strings.TrimSpace(os.Getenv("GITHUB_OUTPUT"))
	if path == "" {
		return nil
	}
	f, err := os.OpenFile(path, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0o644)
	if err != nil {
		return fmt.Errorf("GITHUB_OUTPUT: %w", err)
	}
	defer f.Close()
	if _, err := fmt.Fprintf(f, "%s=%s\n", key, value); err != nil {
		return fmt.Errorf("GITHUB_OUTPUT: %w", err)
	}
	return nil
}
