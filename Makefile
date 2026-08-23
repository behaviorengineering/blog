# Local tasks for this Hugo site. CI runs the same targets: `make build` in .github/actions/hugo-build, link-check runs `make verify check-links`.
HUGO ?= hugo
HUGO_FLAGS := --minify --gc
# For PR previews: include content that production normally excludes, and use a non-production
# environment so list/home filters (filter-pages-released-as-of-now) keep future-dated rows.
# Analytics (GTM / Meta Pixel) stay off because they require hugo.Environment == production.
HUGO_PREVIEW_FLAGS := --environment preview --buildDrafts --buildFuture --buildExpired

# Default target date for social posting (Australia/Sydney).
DATE ?= $(shell TZ=Australia/Sydney date +%F)
# Safety default: dry-run unless explicitly disabled.
DRY_RUN ?= 1
DRY_FLAG := $(if $(filter 1 true yes,$(DRY_RUN)),-dry-run,)
SOCIAL_POST ?=
SOCIAL_POST_FLAG := $(if $(strip $(SOCIAL_POST)),-post "$(SOCIAL_POST)",)
# Default off: listing recent posts needs r_member_social / r_organization_social (often unavailable). Set 0 to enable API idempotency.
LINKEDIN_DISABLE_IDEMPOTENCY ?= 1
LINKEDIN_IDEMPOTENCY_FLAG := $(if $(filter 1 true yes,$(LINKEDIN_DISABLE_IDEMPOTENCY)),-disable-idempotency,)
# Default off: GET post after publish needs read scope (same as idempotency). Set 0 to enable commentary verify.
LINKEDIN_NO_VERIFY_COMMENTARY ?= 1
LINKEDIN_VERIFY_FLAG := $(if $(filter 0 false no,$(LINKEDIN_NO_VERIFY_COMMENTARY)),,-no-verify-commentary)
# Local TTY runs prompt per bundle by default; set SOCIAL_AUTOPOST_NO_ASK=1 or pass -no-ask to disable.
SOCIAL_AUTOPOST_ASK ?=
SOCIAL_AUTOPOST_NO_ASK ?=
SOCIAL_ASK_FLAG := $(if $(filter 1 true yes,$(SOCIAL_AUTOPOST_ASK)),-ask,) $(if $(filter 1 true yes,$(SOCIAL_AUTOPOST_NO_ASK)),-no-ask,)

.DEFAULT_GOAL := help

.PHONY: help all deps tidy build tag-register calendar publish-calendar facebook-autopost linkedin-autopost social-autopost serve server serve-down serve-cleanup down test lint clean list verify check-links substack-html-sample substack-draft sb-html sb-en sb-en-pick sb-en-pick-publish sb-es sb-es-pick-publish sb-list-unpublished sb-mark-published sb-config-init sb-login sb-cc mermaid-render mermaid-render-en mermaid-render-es mermaid motif-editor carousel-pdf carousel-save

all: build

help:
	@echo "Targets:"
	@echo "  make sync-content-ai   Copy selected .cursor skills/rules into content-ai/ for Continue agents"
	@echo "  make tag-register Scan content tags + deprecations -> data/tag-register.txt (runs before hugo on build)"
	@echo "  make calendar          Scan content -> static/calendar/publish-calendar.json (open /calendar/ under make serve)"
	@echo "  make facebook-autopost  Post linkedin.txt to Facebook (DATE=; DRY_RUN=1 default; prompt: publish vs tag-as-published)"
	@echo "  make linkedin-autopost  Post linkedin.txt to LinkedIn (DATE=; DRY_RUN=1 default; idempotency off; prompt: publish vs tag-as-published)"
	@echo "  make social-autopost    Run both facebook-autopost and linkedin-autopost"
	@echo "  make build        Regenerate tag register, then production-like build -> public/ (hugo --minify --gc)"
	@echo "                    Optional: BASE_URL=https://... HUGO_PREVIEW=1 make build (PR previews: future posts in lists)"
	@echo "  make serve        process-compose: hugo (drafts + future), content-pipelines-mcp, carousel-save; Go cmds rebuild on .go save (alias: server)"
	@echo "  make serve-down   stop process-compose and free ports 3848/3849 (alias: down)"
	@echo "  make motif-editor Local motif mask editor (tools/motif-editor; http://localhost:3847)"
	@echo "  make carousel-pdf  LinkedIn PDF from studio WebPs (DIR= folder; SLUG=; optional OUT= VARIANT=)"
	@echo "  make carousel-save Local API so studio Save can write carousel.json (http://127.0.0.1:3848)"
	@echo "  make server       Same as serve"
	@echo "  make test         Smoke build (same as build)"
	@echo "  make lint         go mod verify + build"
	@echo "  make deps         go mod verify"
	@echo "  make tidy         go mod tidy + verify (after editing go.mod)"
	@echo "  make clean        Remove public/, resources/_gen/, hugo cache files"
	@echo "  make list         hugo list all (permalinks)"
	@echo "  make verify       go mod verify"
	@echo "  make check-links  Fresh build, threaded static server, muffet crawl (scripts/check-links.sh)"
	@echo "  make sb-html      Regenerate EN + ES sample HTML under docs/substack-html/ (Substack paste preview)"
	@echo "  make sb-en     Paste into Substack (English; root substack.json; SUBSTACK_URL optional if post_editor_url in substack.json)"
	@echo "                    No POST in env or on CLI: interactive picker (same unpublished list as sb-en-pick, then paste-schedule). Else POST=… or: make sb-en human-condition/2026-05-01-ego-as-game"
	@echo "                    make sb-list-unpublished prints that list only (no paste). SUBSTACK_ACTION=list-unpublished does the same."
	@echo "                    CONFIRM_DISMISS=1 (default): paste-schedule: Continue (default)/Close after paste, then Publish (default)/Keep open after automation; paste-only: one prompt before close"
	@echo "                    Default SUBSTACK_ACTION=paste-schedule (Continue + section/tags/schedule); SUBSTACK_ACTION=paste for body only"
	@echo "  make sb-es     Spanish publication: merge substack.json + overlay; same POST rules as sb-en (picker vs explicit path) → index.es.md"
	@echo "  make sb-login     Open Substack and wait for login (keeps window open; Ctrl+C to stop)"
	@echo "  make sb-config-init  Create substack.json from example if missing"
	@echo "  make sb-list-unpublished  Non-draft bundles still missing target line in social-published (default PUBLISH_TARGET=substack-en)"
	@echo "  make sb-mark-published POST=section/slug  Append target+date to social-published (PUBLISH_TARGET=linkedin, substack-es, ...)"
	@echo "  make mermaid human-condition/2026-04-10-empathy-levels  EN + ES WebP in parallel (make -j2; needs both .mmd and .es.mmd)"

deps verify:
	go mod verify

tidy:
	go mod tidy
	go mod verify

TAG_DEP ?= data/tag-deprecations.toml
TAG_OUT ?= data/tag-register.txt

tag-register:
	go run ./cmd/tag-register -content content -deprecations "$(TAG_DEP)" -out "$(TAG_OUT)"

sync-content-ai:
	bash ./scripts/sync-content-ai.sh

calendar:
	go run ./cmd/publish-calendar -content content -out static/calendar/publish-calendar.json

publish-calendar: calendar

linkedin-autopost:
	go run ./cmd/linkedin-autopost -root . -date "$(DATE)" $(SOCIAL_POST_FLAG) $(LINKEDIN_IDEMPOTENCY_FLAG) $(LINKEDIN_VERIFY_FLAG) $(SOCIAL_ASK_FLAG) $(DRY_FLAG)

facebook-autopost:
	go run ./cmd/facebook-autopost -date "$(DATE)" $(SOCIAL_POST_FLAG) $(SOCIAL_ASK_FLAG) $(DRY_FLAG)

social-autopost: facebook-autopost linkedin-autopost

# GitHub Pages serves extensionless bundle sidecars as application/octet-stream; rename to
# carousel.preview.html so /.../carousel.preview resolves as text/html (Pages strips .html).
.PHONY: carousel-preview-html
carousel-preview-html:
	@find public -name 'carousel.preview' -type f -exec sh -c 'mv "$$1" "$$1.html"' _ {} \;

# Match CI: only pass --baseURL when non-empty (GitHub Actions often sets BASE_URL="" for production).
build: tag-register
ifneq ($(strip $(HUGO_PREVIEW)),)
	$(eval HUGO_FLAGS := $(HUGO_FLAGS) $(HUGO_PREVIEW_FLAGS))
endif
ifneq ($(strip $(BASE_URL)),)
	$(HUGO) $(HUGO_FLAGS) --baseURL "$(BASE_URL)"
else
	$(HUGO) $(HUGO_FLAGS)
endif
	@$(MAKE) carousel-preview-html

# LinkedIn document PDF from studio slide exports (`{slug}-slide-NN-a.webp`).
# Example: make carousel-pdf DIR=$$HOME/Downloads SLUG=why-humans-keep-building-pyramids
DIR ?=
SLUG ?=
OUT ?=
VARIANT ?=
carousel-pdf:
	@test -n "$(DIR)" || (echo "DIR= is required (folder of studio WebP exports)"; exit 1)
	go run ./cmd/carousel-pdf -dir "$(DIR)" $(if $(SLUG),-slug "$(SLUG)",) $(if $(VARIANT),-variant "$(VARIANT)",) $(if $(OUT),-o "$(OUT)",)

carousel-save:
	go run ./cmd/carousel-save -addr "127.0.0.1:3848" -root .

serve-cleanup:
	@./scripts/serve-cleanup.sh

serve-down down:
	@./scripts/serve-cleanup.sh

serve server:
	@chmod +x scripts/serve-process.sh scripts/serve-cleanup.sh scripts/link-providers.sh
	@./scripts/link-providers.sh
	@./scripts/serve-cleanup.sh --preflight
	@trap './scripts/serve-cleanup.sh' EXIT INT TERM; process-compose up -f process-compose.yaml

test: build

lint: deps build

clean:
	rm -rf public resources/_gen hugo_stats.json .hugo_build.lock

list:
	$(HUGO) list all

check-links:
	./scripts/check-links.sh

substack-html-sample:
	go run ./cmd/substack-html -in content/mind-infrastructure/2026-04-29-free-energy-principle-hallucination-machine/index.md -out docs/substack-html/sample-free-energy.html
	go run ./cmd/substack-html -in content/mind-infrastructure/2026-04-29-free-energy-principle-hallucination-machine/index.es.md -out docs/substack-html/sample-free-energy.es.html
	@printf '\n✅  sample HTML written\n\n   📤  docs/substack-html/sample-free-energy.html\n   📤  docs/substack-html/sample-free-energy.es.html\n\n   👉  Preview paste shape:\n       open those files in a browser\n\n'

# Substack draft paste (requires Chrome/Chromium). Target URL: optional SUBSTACK_URL when substack.json post_editor_url is set (paste + paste-schedule), else SUBSTACK_PUB or wait-login flow.
# - SUBSTACK_URL='https://<pub>.substack.com/...' overrides post_editor_url when you need a one-off tab URL.
# - SUBSTACK_PUB='<pub>' and then click New post during WAIT_LOGIN.
# For Spanish (second publication), set SUBSTACK_LANG=es or use make sb-es (merges overlay; needs root substack.json). English: make substack-draft or make sb-en.
#
# Positional post path (convenience so you can skip POST=):
#   make sb-en path/to/post
#   make sb-mark-published human-condition/2026-05-01-ego-as-game
# When the first goal is one of the draft/mark targets below, Make looks at the *second* word on the command line
# (MAKECMDGOALS word 2). If that word is not in _SB_KNOWN_TARGETS and it contains a '/', we treat it as a bundle path
# under content/ and set POST from it (unless POST was already set on the command line or in the environment).
# This is a heuristic: if you add a new top-level phony target that can appear as the second argument, add it to
# _SB_KNOWN_TARGETS so it is not mistaken for a post path. Paths must include '/' so plain words like "help" are not
# picked up. Folder forms: section/slug, content/section/slug, optional trailing slash; index.md / index.es.md are
# stripped later via _POST_NORM. Mark published also accepts: make sb-mark-published POST=section/slug.
_SB_KNOWN_TARGETS := help all deps tidy build tag-register calendar publish-calendar facebook-autopost linkedin-autopost social-autopost serve server serve-down serve-cleanup down test lint clean list verify check-links substack-html-sample substack-draft sb-html sb-en sb-en-pick sb-en-pick-publish sb-es sb-es-pick-publish sb-list-unpublished sb-mark-published sb-config-init sb-login sb-cc mermaid-render mermaid-render-en mermaid-render-es mermaid carousel-pdf carousel-save
_SB_FIRST_GOAL := $(firstword $(MAKECMDGOALS))
_SB_SECOND_GOAL := $(word 2,$(MAKECMDGOALS))
ifneq ($(filter $(_SB_FIRST_GOAL),sb-en sb-es sb-en-pick sb-en-pick-publish sb-es-pick-publish substack-draft sb-mark-published),)
ifneq ($(_SB_SECOND_GOAL),)
ifeq ($(filter $(_SB_SECOND_GOAL),$(_SB_KNOWN_TARGETS)),)
ifneq ($(findstring /,$(_SB_SECOND_GOAL)),)
_SB_DRAFT_POS := $(_SB_SECOND_GOAL)
endif
endif
endif
endif
ifneq ($(_SB_DRAFT_POS),)
ifneq ($(origin POST),command line)
ifneq ($(origin POST),environment)
override POST := $(_SB_DRAFT_POS)
endif
endif
.PHONY: $(_SB_DRAFT_POS)
$(_SB_DRAFT_POS):
	@:
endif
# Positional bundle for mermaid / mermaid-render-en / mermaid-render-es (same second-goal rule as sb-en / sb-es / substack-draft).
_MR_FIRST := $(firstword $(MAKECMDGOALS))
_MR_SECOND := $(word 2,$(MAKECMDGOALS))
_MR_GOALS := mermaid mermaid-render-en mermaid-render-es
ifneq ($(filter $(_MR_FIRST),$(_MR_GOALS)),)
ifneq ($(_MR_SECOND),)
ifeq ($(filter $(_MR_SECOND),$(_SB_KNOWN_TARGETS)),)
ifneq ($(findstring /,$(_MR_SECOND)),)
_MERMAID_BUNDLE_POS := $(_MR_SECOND)
endif
endif
endif
endif
ifneq ($(_MERMAID_BUNDLE_POS),)
ifneq ($(origin POST),command line)
ifneq ($(origin POST),environment)
override POST := $(_MERMAID_BUNDLE_POS)
endif
endif
.PHONY: $(_MERMAID_BUNDLE_POS)
$(_MERMAID_BUNDLE_POS):
	@:
endif
POST ?= mind-infrastructure/2026-04-29-free-energy-principle-hallucination-machine

# Mermaid CLI in Docker (@mermaid-js/mermaid-cli); pin image for reproducible renders.
MERMAID_DOCKER_IMAGE ?= minlag/mermaid-cli:11.12.0
MERMAID_WIDTH ?=
MERMAID_HEIGHT ?=
MERMAID_BACKGROUND ?=
MERMAID_WEBP_QUALITY ?=
MERMAID_WEBP_LOSSLESS ?=
# Bundle-relative diagram basename (files: $(MERMAID_STEM).mmd / .webp for EN; $(MERMAID_STEM).es.mmd / .es.webp for ES).
MERMAID_STEM ?= diagram
_POST_NORM := $(patsubst content/%,%,$(POST))
_POST_NORM := $(patsubst %/,%,$(_POST_NORM))
_POST_NORM := $(patsubst %/index.md,%,$(_POST_NORM))
_POST_NORM := $(patsubst %/index.es.md,%,$(_POST_NORM))
ifneq ($(origin SUBSTACK_IN),command line)
ifneq ($(origin SUBSTACK_IN),environment)
override SUBSTACK_IN := content/$(_POST_NORM)/index.md
endif
endif
ifneq ($(origin SUBSTACK_IN_ES),command line)
ifneq ($(origin SUBSTACK_IN_ES),environment)
override SUBSTACK_IN_ES := content/$(_POST_NORM)/index.es.md
endif
endif
SUBSTACK_ACTION ?= paste-schedule
PUBLISH_TARGET ?= substack-en
SUBSTACK_LANG ?=
SUBSTACK_OVERLAY_EN ?= substack.overlay.en.json
SUBSTACK_OVERLAY_ES ?= substack.overlay.es.json
WAIT_LOGIN ?= 0s
KEEP_OPEN ?= 30s
CONFIRM_DISMISS ?= 1
# Extra flags for go run ./cmd/substack-draft. If you pass more than one flag, quote the value (BSD / Apple make splits on spaces).
SUBSTACK_DRAFT_FLAGS ?=
PASTE_TIMEOUT ?= 12m
CHROME_PROFILE ?= $(HOME)/.cache/substack-chrome-profile

substack-draft:
	@merge=''; \
	if [ "$(SUBSTACK_LANG)" = "es" ]; then \
		merge='-config-global substack.json -config $(SUBSTACK_OVERLAY_ES)'; \
	elif [ "$(SUBSTACK_LANG)" = "en" ]; then \
		merge='-config-global substack.json -config $(SUBSTACK_OVERLAY_EN)'; \
	fi; \
	dismiss=''; \
	if [ "$(CONFIRM_DISMISS)" = "1" ]; then \
		dismiss='-confirm-dismiss -keep-open 0'; \
	else \
		dismiss="-keep-open $(KEEP_OPEN)"; \
	fi; \
	if [ -n "$(SUBSTACK_URL)" ]; then \
		go run ./cmd/substack-draft $$merge -action "$(SUBSTACK_ACTION)" -url "$(SUBSTACK_URL)" -in "$(SUBSTACK_IN)" -chrome-user-data-dir "$(CHROME_PROFILE)" -paste-timeout "$(PASTE_TIMEOUT)" -publish-target "$(PUBLISH_TARGET)" $(SUBSTACK_DRAFT_FLAGS) $$dismiss; \
	elif [ -n "$(SUBSTACK_PUB)" ]; then \
		go run ./cmd/substack-draft $$merge -action "$(SUBSTACK_ACTION)" -pub "$(SUBSTACK_PUB)" -in "$(SUBSTACK_IN)" -chrome-user-data-dir "$(CHROME_PROFILE)" -wait-login "$(WAIT_LOGIN)" -paste-timeout "$(PASTE_TIMEOUT)" -publish-target "$(PUBLISH_TARGET)" $(SUBSTACK_DRAFT_FLAGS) $$dismiss; \
	else \
		go run ./cmd/substack-draft $$merge -action "$(SUBSTACK_ACTION)" -in "$(SUBSTACK_IN)" -chrome-user-data-dir "$(CHROME_PROFILE)" -wait-login "$(WAIT_LOGIN)" -paste-timeout "$(PASTE_TIMEOUT)" -publish-target "$(PUBLISH_TARGET)" $(SUBSTACK_DRAFT_FLAGS) $$dismiss; \
	fi

# Short aliases (prefer these in day-to-day use).
sb-html: substack-html-sample
# Plain sb-en / sb-es: interactive pick when POST is only the Makefile default (origin default|automatic).
# Explicit POST: env, command line, override (positional path), or Makefile override → paste that bundle.
sb-en:
	@case "$(origin POST)" in \
	  default|automatic|file) $(MAKE) substack-draft SUBSTACK_ACTION=pick-draft-en ;; \
	  *) $(MAKE) substack-draft ;; \
	esac
sb-en-pick:
	@$(MAKE) substack-draft SUBSTACK_ACTION=pick-draft-en
sb-en-pick-publish:
	@$(MAKE) substack-draft SUBSTACK_ACTION=pick-draft-en CONFIRM_DISMISS=0 KEEP_OPEN=8s SUBSTACK_DRAFT_FLAGS="-schedule-max-attempts=2"
sb-list-unpublished:
	go run ./cmd/substack-draft -action list-unpublished -content-root content -publish-target "$(PUBLISH_TARGET)"
sb-mark-published:
	@test -f "content/$(_POST_NORM)/index.md" || (printf '\n❌  missing bundle: content/%s/index.md\n\n   Set POST=section/slug (path under content/).\n\n   👉  Example:\n       make sb-mark-published human-condition/2026-05-01-ego-as-game\n\n' "$(_POST_NORM)" >&2; exit 1)
	go run ./cmd/substack-draft -action mark-published -in "content/$(_POST_NORM)/index.md" -publish-target "$(PUBLISH_TARGET)"
sb-es:
	@case "$(origin POST)" in \
	  default|automatic|file) $(MAKE) substack-draft SUBSTACK_LANG=es SUBSTACK_ACTION=pick-draft-es PUBLISH_TARGET=substack-es ;; \
	  *) $(MAKE) substack-draft SUBSTACK_LANG=es SUBSTACK_IN=$(SUBSTACK_IN_ES) POST="$(POST)" PUBLISH_TARGET=substack-es ;; \
	esac
sb-es-pick-publish:
	@$(MAKE) substack-draft SUBSTACK_LANG=es SUBSTACK_ACTION=pick-draft-es PUBLISH_TARGET=substack-es SUBSTACK_IN=$(SUBSTACK_IN_ES) POST="$(POST)" CONFIRM_DISMISS=0 KEEP_OPEN=8s SUBSTACK_DRAFT_FLAGS="-schedule-max-attempts=2"

sb-login:
	go run ./cmd/substack-draft -action login -chrome-user-data-dir "$(CHROME_PROFILE)" -paste-timeout 0 -keep-open 0

sb-cc:
	go run ./cmd/substack-draft -action cc -chrome-user-data-dir "$(CHROME_PROFILE)" -paste-timeout "$(PASTE_TIMEOUT)" -keep-open "$(KEEP_OPEN)"

sb-config-init:
	@if [ -f substack.json ]; then \
		printf 'ℹ️  substack.json already exists\n'; \
	else \
		cp docs/substack-html/substack-config.example.json substack.json; \
		printf '\n✅  created substack.json\n\n   Chrome profile: use direnv .envrc + SUBSTACK_CHROMIUM_USER_DATA_DIRECTORY\n\n'; \
	fi

mermaid-render:
	@if [ -z "$(strip $(IN))" ] || [ -z "$(strip $(OUT))" ]; then \
		echo 'Usage: make mermaid-render IN=path/to/diagram.mmd OUT=path/to/out.webp (or .png, .svg)'; \
		echo 'Example: make mermaid-render IN=content/human-condition/2026-04-10-empathy-levels/empathy-stack.mmd OUT=content/human-condition/2026-04-10-empathy-levels/empathy-stack.webp'; \
		echo 'Optional: MERMAID_DOCKER_IMAGE=$(MERMAID_DOCKER_IMAGE) MERMAID_WIDTH=2400 MERMAID_HEIGHT=1600 MERMAID_BACKGROUND=transparent MERMAID_WEBP_QUALITY=80 MERMAID_WEBP_LOSSLESS=1'; \
		exit 2; \
	fi
	@MERMAID_WIDTH="$(MERMAID_WIDTH)" MERMAID_HEIGHT="$(MERMAID_HEIGHT)" MERMAID_BACKGROUND="$(MERMAID_BACKGROUND)" \
		MERMAID_WEBP_QUALITY="$(MERMAID_WEBP_QUALITY)" MERMAID_WEBP_LOSSLESS="$(MERMAID_WEBP_LOSSLESS)" \
		./scripts/mermaid-docker.sh "$(IN)" "$(OUT)" "$(MERMAID_DOCKER_IMAGE)"

mermaid-render-en:
	@test -f "content/$(_POST_NORM)/$(MERMAID_STEM).mmd" || (printf '\n❌  missing content/%s/%s.mmd\n\n   Add that file (Mermaid body only) or MERMAID_STEM=myname for myname.mmd.\n\n   👉  Example:\n       make mermaid-render-en human-condition/slug\n\n' "$(_POST_NORM)" "$(MERMAID_STEM)" >&2; exit 1)
	@$(MAKE) mermaid-render IN=content/$(_POST_NORM)/$(MERMAID_STEM).mmd OUT=content/$(_POST_NORM)/$(MERMAID_STEM).webp

mermaid-render-es:
	@test -f "content/$(_POST_NORM)/$(MERMAID_STEM).es.mmd" || (printf '\n❌  missing content/%s/%s.es.mmd\n\n   Add Spanish Mermaid source or MERMAID_STEM=...\n\n   👉  Example:\n       make mermaid-render-es human-condition/slug\n\n' "$(_POST_NORM)" "$(MERMAID_STEM)" >&2; exit 1)
	@$(MAKE) mermaid-render IN=content/$(_POST_NORM)/$(MERMAID_STEM).es.mmd OUT=content/$(_POST_NORM)/$(MERMAID_STEM).es.webp

mermaid:
	@test -f "content/$(_POST_NORM)/$(MERMAID_STEM).mmd" || (printf '\n❌  missing content/%s/%s.mmd\n\n   👉  Example:\n       make mermaid human-condition/slug\n\n' "$(_POST_NORM)" "$(MERMAID_STEM)" >&2; exit 1)
	@test -f "content/$(_POST_NORM)/$(MERMAID_STEM).es.mmd" || (printf '\n❌  missing content/%s/%s.es.mmd\n\n   Add Spanish Mermaid or use mermaid-render-en only.\n\n' "$(_POST_NORM)" "$(MERMAID_STEM)" >&2; exit 1)
	@$(MAKE) -j2 POST="$(POST)" \
		MERMAID_DOCKER_IMAGE="$(MERMAID_DOCKER_IMAGE)" MERMAID_STEM="$(MERMAID_STEM)" \
		MERMAID_WIDTH="$(MERMAID_WIDTH)" MERMAID_HEIGHT="$(MERMAID_HEIGHT)" MERMAID_BACKGROUND="$(MERMAID_BACKGROUND)" \
		MERMAID_CSS="$(MERMAID_CSS)" MERMAID_WEBP_QUALITY="$(MERMAID_WEBP_QUALITY)" MERMAID_WEBP_LOSSLESS="$(MERMAID_WEBP_LOSSLESS)" \
		mermaid-render-en mermaid-render-es

.PHONY: motif-editor
motif-editor:
	@go run ./cmd/motif-editor

