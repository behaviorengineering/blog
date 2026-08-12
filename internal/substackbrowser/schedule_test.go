package substackbrowser

import (
	"strings"
	"testing"
)

func TestScheduleAfterContinueJSMarshals(t *testing.T) {
	js, err := ScheduleAfterContinueJS(ScheduleAfterContinueOptions{
		Tags:              []string{"A", "B"},
		SectionLabel:      "Mind Infrastructure",
		DateTimeLocal:     "2026-05-01T09:00",
		DateDisplay:       "29/04/2026, 08:40 am",
		TickEmailSubstack: true,
	})
	if err != nil {
		t.Fatal(err)
	}
	if !strings.Contains(js, `"tags"`) || !strings.Contains(js, `"dateDisplay"`) || !strings.Contains(js, `"Mind Infrastructure"`) {
		head := js
		if len(head) > 200 {
			head = head[:200]
		}
		t.Fatalf("unexpected script head: %s", head)
	}
}
