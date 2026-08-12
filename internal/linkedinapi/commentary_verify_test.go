package linkedinapi

import (
	"strings"
	"testing"
)

func TestVerifyCommentary_ok_fullPost(t *testing.T) {
	source := strings.TrimSpace(`
#StreetWisdom #ArepaContigo

🧷 Full post (site) →
- ES: https://behaviorengineering.ai/es/cognitive-memetics/sayings/2026-05-25-saying-20/
- EN: https://behaviorengineering.ai/cognitive-memetics/sayings/2026-05-25-saying-20/

🔗 Por-Estas-Calles (English) → https://behaviorengineering.ai/categories/por-estas-calles/
`)
	encoded := EncodeCommentaryForPostsAPI(source)
	if err := VerifyCommentary(source, encoded, encoded); err != nil {
		t.Fatal(err)
	}
}

func TestVerifyCommentary_missingURLs(t *testing.T) {
	source := "see https://behaviorengineering.ai/cognitive-memetics/cows/w13/\n"
	stored := "see https://behaviorengineering.ai/cognitive-memetics/\n"
	if err := VerifyCommentary(source, stored, ""); err == nil {
		t.Fatal("expected missing URL error")
	}
}

func TestVerifyCommentary_truncatedFooter(t *testing.T) {
	source := strings.TrimSpace(`
#StreetWisdom #ArepaContigo

🧷 Full post (site) →
- EN: https://behaviorengineering.ai/cognitive-memetics/sayings/2026-05-25-saying-20/

🔗 Por-Estas-Calles (English) → https://behaviorengineering.ai/categories/por-estas-calles/
`)
	// Truncation after hashtag line (no URLs, no footers).
	stored := "#StreetWisdom\n\n✔️ TLDR:\nShort body only."
	if err := VerifyCommentary(source, stored, ""); err == nil {
		t.Fatal("expected truncation/footer error")
	}
}

func TestVerifyCommentary_missingHashtagTag(t *testing.T) {
	source := "#StreetWisdom #ArepaContigo\n\nhttps://behaviorengineering.ai/x/\n"
	stored := "{hashtag|\\#|StreetWisdom}\n\nhttps://behaviorengineering.ai/x/\n"
	if err := VerifyCommentary(source, stored, ""); err == nil {
		t.Fatal("expected missing ArepaContigo error")
	}
}

func TestVerifyCommentary_tooShort(t *testing.T) {
	source, _ := readFixtureW20Source(t)
	stored := source[:200]
	if err := VerifyCommentary(source, stored, ""); err == nil {
		t.Fatal("expected length error")
	}
}

func TestVerifyCommentary_unclosedHashtagTemplate(t *testing.T) {
	source := "#Tag\n\nhttps://behaviorengineering.ai/x/\n"
	stored := "{hashtag|\\#|Tag\n\nhttps://behaviorengineering.ai/x/\n"
	if err := VerifyCommentary(source, stored, ""); err == nil {
		t.Fatal("expected unclosed template error")
	}
}

func readFixtureW20Source(t *testing.T) (string, string) {
	t.Helper()
	source := strings.TrimSpace(`
W20: Street-Wisdom 💬🇻🇪
"El diablo sabe más por viejo que por diablo."

✔️ TLDR:
The devil claims intelligence for two reasons: his infamous name, and his long life.

➕ FLUFF:
It carries warm respect for people who earned their read on the world.

❓ BUT WHY:
This is an informal experiment: counting Venezuelan sayings while a political era runs its course.

#StreetWisdom #CulturalStopwatch #TakeBackYourMcDonaldsCulture #ArepaContigo #VenezuelanSayings #Moderation

🧷 Full post (site) →
- ES: https://behaviorengineering.ai/es/cognitive-memetics/sayings/2026-05-25-saying-20/
- EN: https://behaviorengineering.ai/cognitive-memetics/sayings/2026-05-25-saying-20/

🔗 Por-Estas-Calles (English) → https://behaviorengineering.ai/categories/por-estas-calles/
`)
	return source, EncodeCommentaryForPostsAPI(source)
}
