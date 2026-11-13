package socialautopost

import (
	"os"
	"path/filepath"
	"testing"
)

func TestWriteGitHubOutputNoopWhenUnset(t *testing.T) {
	t.Setenv("GITHUB_OUTPUT", "")
	if err := WriteGitHubOutput("facebook_posted", "true"); err != nil {
		t.Fatalf("WriteGitHubOutput: %v", err)
	}
}

func TestWriteGitHubOutputAppendsKey(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "github_output")
	if err := os.WriteFile(path, []byte("post_date=2026-11-13\n"), 0o644); err != nil {
		t.Fatalf("WriteFile: %v", err)
	}
	t.Setenv("GITHUB_OUTPUT", path)

	if err := WriteGitHubOutput("facebook_posted", "true"); err != nil {
		t.Fatalf("WriteGitHubOutput: %v", err)
	}

	got, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("ReadFile: %v", err)
	}
	want := "post_date=2026-11-13\nfacebook_posted=true\n"
	if string(got) != want {
		t.Fatalf("GITHUB_OUTPUT = %q, want %q", got, want)
	}
}
