package linkedinapi

import "testing"

func TestYouTubeURLs(t *testing.T) {
	id := "pO0WZsN8Oiw"
	if got := YouTubeWatchURL(id); got != "https://www.youtube.com/watch?v=pO0WZsN8Oiw" {
		t.Fatalf("watch: %q", got)
	}
	if got := YouTubeThumbnailURL(id); got != "https://img.youtube.com/vi/pO0WZsN8Oiw/hqdefault.jpg" {
		t.Fatalf("thumb: %q", got)
	}
}

func TestExtractYouTubeVideoID(t *testing.T) {
	txt := "▶️ watch →\n- https://www.youtube.com/watch?v=pO0WZsN8Oiw\n"
	if got := ExtractYouTubeVideoID(txt); got != "pO0WZsN8Oiw" {
		t.Fatalf("got %q", got)
	}
}
