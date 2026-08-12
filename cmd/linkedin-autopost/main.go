// Command linkedin-autopost posts each matching bundle's linkedin.txt to LinkedIn using the Posts API.
// It is designed for GitHub Actions: no repo state writes, optional idempotency by checking whether the
// bundle URL already appears in recent LinkedIn posts.
//
// Bundle selection matches facebook-autopost (see internal/socialbundle and internal/contentbundle).
package main

import (
	"context"
	"errors"
	"flag"
	"log"
	"os"
	"strings"
	"time"

	"github.com/xynova/behaviour-engineering/internal/cliout"
	"github.com/xynova/behaviour-engineering/internal/linkedinapi"
	"github.com/xynova/behaviour-engineering/internal/socialautopost"
	"github.com/xynova/behaviour-engineering/internal/socialbundle"
	"github.com/xynova/behaviour-engineering/internal/substackpublishstate"
)

func main() {
	log.SetFlags(log.LstdFlags | log.Lshortfile)

	root := flag.String("root", ".", "repository root (contains content/)")
	dateStr := flag.String("date", "", "Target date YYYY-MM-DD (required)")
	postPath := flag.String("post", os.Getenv("SOCIAL_POST"), "Optional bundle path under content/ when multiple bundles share the same date; same as facebook-autopost -post; or env SOCIAL_POST")
	authorURN := flag.String("author", os.Getenv("LINKEDIN_AUTHOR_URN"), "Author URN (urn:li:person:... or urn:li:organization:...), or env LINKEDIN_AUTHOR_URN")
	token := flag.String("token", os.Getenv("LINKEDIN_ACCESS_TOKEN"), "Access token, or env LINKEDIN_ACCESS_TOKEN")
	linkedinVersion := flag.String("linkedin-version", "", "LinkedIn API version header YYYYMM (overrides env LINKEDIN_VERSION; default: "+linkedinapi.DefaultLinkedInVersion+")")
	timeout := flag.Duration("http-timeout", 30*time.Second, "HTTP timeout")
	dryRun := flag.Bool("dry-run", false, "Log what would be posted; do not call LinkedIn")
	recentCount := flag.Int("recent-count", 50, "How many recent posts to scan for idempotency (max 100)")
	disableIdempotency := flag.Bool("disable-idempotency", false, "Skip recent-post scan (no r_member_social / r_organization_social). Same if env LINKEDIN_DISABLE_IDEMPOTENCY is 1, true, yes, or on")
	skipLittleText := flag.Bool("skip-little-text-encode", false, "Send linkedin.txt as plain commentary (no hashtag templates or escapes); not recommended")
	noVerify := flag.Bool("no-verify-commentary", false, "Skip GET post after publish to confirm stored commentary (URLs, footers, hashtags, length)")
	askEach := flag.Bool("ask", false, "Prompt publish or skip for each bundle (also SOCIAL_AUTOPOST_ASK=1)")
	noAsk := flag.Bool("no-ask", false, "Never prompt; post every bundle that passes idempotency (CI default)")
	noMarkPublished := flag.Bool("no-mark-published", false, "Do not write social-published in the bundle (also SOCIAL_AUTOPOST_NO_MARK=1)")
	flag.Parse()

	verifyCommentary := !*noVerify && !envNoVerifyCommentary()
	skipRecentPostScan := *disableIdempotency || envDisablesLinkedInIdempotency()
	promptEach := socialautopost.PromptEnabled(*askEach, *noAsk)
	noMark := *noMarkPublished || envNoMarkPublished()
	publishTarget := substackpublishstate.TargetLinkedIn
	if promptEach {
		log.Printf("interactive: will ask publish or skip for each bundle (stdin is a TTY; use -no-ask to disable)")
	}

	if strings.TrimSpace(*dateStr) == "" {
		log.Fatal("-date is required (YYYY-MM-DD)")
	}
	if !*dryRun {
		if strings.TrimSpace(*authorURN) == "" || strings.TrimSpace(*token) == "" {
			log.Fatal("author and token are required unless -dry-run (use flags or LINKEDIN_AUTHOR_URN and LINKEDIN_ACCESS_TOKEN)")
		}
	}

	bundles, err := socialbundle.LoadBundlesForPublishDate(*root, strings.TrimSpace(*dateStr), strings.TrimSpace(*postPath))
	if err != nil {
		log.Fatalf("select bundles: %v", err)
	}
	if len(bundles) == 0 {
		cliout.PrintSocialAutopostEmpty(os.Stdout, "LinkedIn", strings.TrimSpace(*dateStr), strings.TrimSpace(*postPath))
		return
	}

	encodeLittleText := !*skipLittleText

	if *dryRun && skipRecentPostScan {
		socialbundle.PrintDryRunLinkedInIdempotencySkipped(os.Stdout)
	}

	var (
		ctx    context.Context
		client *linkedinapi.Client
		posts  []linkedinapi.PostElement
	)
	if !*dryRun {
		cliout.PrintSocialAutopostStart(os.Stdout, "LinkedIn", len(bundles), 0)
		liVer := strings.TrimSpace(*linkedinVersion)
		if liVer == "" {
			liVer = strings.TrimSpace(os.Getenv("LINKEDIN_VERSION"))
		}

		ctx = context.Background()
		client = linkedinapi.NewClient(*timeout, *token, liVer)
		client.RequestLogger = func(method, url string, status int, preview string) {
			log.Printf("linkedin: %s %s -> %d", method, url, status)
		}

		if !skipRecentPostScan {
			var err error
			posts, err = client.FindRecentPostsByAuthor(ctx, *authorURN, *recentCount)
			if err != nil {
				log.Fatalf("find posts: %v", err)
			}
			log.Printf("idempotency: loaded %d recent posts for author", len(posts))
		} else {
			log.Printf("idempotency: disabled (-disable-idempotency or LINKEDIN_DISABLE_IDEMPOTENCY), posting without recent-post scan")
		}
	}

	for i, b := range bundles {
		visualCard := b.HasLinkedInVisualCard()
		if err := socialautopost.ValidateLinkedInTxt(b.Message, visualCard); err != nil {
			log.Fatalf("content/%s: %v", b.RelUnderContent, err)
		}
		plan := linkedinapi.PrepareCommentary(b.Message, visualCard, encodeLittleText)
		linkedinapi.LogCommentaryPlan(plan)

		alreadyMarked, err := socialautopost.MarkerHasTarget(b.BundleDir, publishTarget)
		if err != nil {
			log.Fatalf("content/%s: social-published: %v", b.RelUnderContent, err)
		}
		if alreadyMarked {
			cliout.PrintSocialSkipAlreadyMarked(os.Stdout, publishTarget, b.RelUnderContent)
			continue
		}

		idempotencySkipped := false
		if !*dryRun && !skipRecentPostScan {
			log.Printf("idempotency: scanning recent posts for URL %s", b.PostURL)
			for _, p := range posts {
				if strings.Contains(p.Commentary, b.PostURL) {
					log.Printf("skip: already posted (found URL in %s)", p.ID)
					idempotencySkipped = true
					break
				}
			}
		}

		if promptEach {
			choice, err := socialautopost.ConfirmPublishItem(socialautopost.ItemPrompt{
				Index:              i,
				Total:              len(bundles),
				RelUnderContent:    b.RelUnderContent,
				PostURL:            b.PostURL,
				Network:            "LinkedIn",
				WithImage:          visualCard,
				DryRun:             *dryRun,
				IdempotencySkipped: idempotencySkipped,
			})
			if err != nil {
				if errors.Is(err, socialautopost.ErrAutopostQuit) {
					log.Printf("stop: %v", err)
					return
				}
				log.Fatalf("prompt: %v", err)
			}
			switch choice {
			case socialautopost.ChoiceTagAsPublished:
				if *dryRun {
					log.Printf("dry-run: tag-as-published (no file write)")
				} else {
					recordPublished(b.BundleDir, publishTarget, false, noMark, "tag-as-published")
				}
				continue
			case socialautopost.ChoiceQuit:
				log.Printf("stop: user quit (%d bundle(s) remaining)", len(bundles)-i-1)
				return
			}
		} else if idempotencySkipped {
			if *dryRun {
				log.Printf("dry-run: already on network (idempotency); no file write")
			} else {
				recordPublished(b.BundleDir, publishTarget, false, noMark, "idempotency")
			}
			continue
		}

		if *dryRun {
			mode := b.LinkedInPostModeLabel()
			if encodeLittleText && plan.EncodedChanged {
				mode += " (little text encoded)"
			}
			thumbURL := ""
			if b.UseLinkedInArticlePost() {
				thumbURL = linkedinapi.YouTubeThumbnailURL(b.YouTubeID)
			}
			socialbundle.PrintDryRunLinkedInItem(os.Stdout, i, len(bundles), mode, b.PostURL, b.FeaturedImagePath, b.YouTubeURL, thumbURL, plan.Encoded)
			continue
		}

		if i > 0 {
			log.Print("------------------------------------------------------------")
		}
		log.Printf("linkedin-autopost: item %d/%d: %s", i+1, len(bundles), b.BundleDir)

		if b.Message == "" {
			log.Fatalf("linkedin.txt is empty: %s", b.LinkedInPath)
		}

		opts, err := linkedInPostOptions(ctx, client, *authorURN, b)
		if err != nil {
			log.Fatalf("prepare post: %v", err)
		}

		postID, err := client.CreatePost(ctx, *authorURN, plan.Encoded, opts)
		if err != nil {
			log.Fatalf("create post: %v", err)
		}
		cliout.PrintSocialPosted(os.Stdout, "LinkedIn", postID)

		if verifyCommentary {
			stored, err := client.GetPost(ctx, postID)
			if err != nil {
				if linkedinapi.IsAccessDenied(err) {
					log.Printf("verify commentary: skipped (no read scope; POST succeeded as %s)", postID)
				} else {
					log.Fatalf("verify commentary: could not fetch post %s: %v", postID, err)
				}
			} else if err := linkedinapi.VerifyCommentary(b.Message, stored.Commentary, plan.Encoded); err != nil {
				log.Fatalf("verify commentary: %v", err)
			} else {
				log.Printf("verify commentary: ok (URLs, footers, hashtags, length; %d site URL(s))", len(plan.SiteURLs))
			}
		}
		recordPublished(b.BundleDir, publishTarget, *dryRun, noMark, "posted")
	}
}

func linkedInPostOptions(ctx context.Context, client *linkedinapi.Client, authorURN string, b *socialbundle.Bundle) (linkedinapi.PostOptions, error) {
	if b.UseLinkedInArticlePost() {
		thumbURL := linkedinapi.YouTubeThumbnailURL(b.YouTubeID)
		log.Printf("uploading YouTube thumbnail: %s", thumbURL)
		data, err := linkedinapi.FetchYouTubeThumbnail(ctx, client.HTTP, b.YouTubeID)
		if err != nil {
			return linkedinapi.PostOptions{}, err
		}
		imageURN, err := client.UploadImageBytes(ctx, authorURN, data, "image/jpeg")
		if err != nil {
			return linkedinapi.PostOptions{}, err
		}
		title := b.ArticleTitle
		if title == "" {
			title = b.AltText
		}
		return linkedinapi.PostOptions{
			Article: &linkedinapi.ArticleContent{
				Source:       b.YouTubeURL,
				ThumbnailURN: imageURN,
				Title:        title,
				Description:  b.ArticleDescription,
			},
		}, nil
	}
	if strings.TrimSpace(b.FeaturedImagePath) != "" {
		log.Printf("uploading image: %s", b.FeaturedImagePath)
		imageURN, err := client.UploadImage(ctx, authorURN, b.FeaturedImagePath)
		if err != nil {
			return linkedinapi.PostOptions{}, err
		}
		return linkedinapi.PostOptions{
			ImageURN: imageURN,
			AltText:  b.AltText,
		}, nil
	}
	return linkedinapi.PostOptions{}, nil
}

func recordPublished(bundleDir, targetKey string, dryRun, noMark bool, reason string) {
	if err := socialautopost.RecordPublished(bundleDir, targetKey, dryRun, noMark); err != nil {
		log.Fatalf("record social-published (%s): %v", reason, err)
	}
	if !dryRun && !noMark {
		cliout.PrintSocialMarkerRecorded(os.Stdout, targetKey, reason)
	}
}

func envNoVerifyCommentary() bool {
	v := strings.TrimSpace(os.Getenv("LINKEDIN_NO_VERIFY_COMMENTARY"))
	switch strings.ToLower(v) {
	case "1", "true", "yes", "on":
		return true
	default:
		return false
	}
}

func envNoMarkPublished() bool {
	v := strings.TrimSpace(os.Getenv("SOCIAL_AUTOPOST_NO_MARK"))
	switch strings.ToLower(v) {
	case "1", "true", "yes", "on":
		return true
	default:
		return false
	}
}

func envDisablesLinkedInIdempotency() bool {
	v := strings.TrimSpace(os.Getenv("LINKEDIN_DISABLE_IDEMPOTENCY"))
	switch strings.ToLower(v) {
	case "1", "true", "yes", "on":
		return true
	default:
		return false
	}
}
