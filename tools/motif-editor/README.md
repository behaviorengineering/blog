# Motif editor

Local web app for preparing carousel motif strip assets: paint a preserve mask, preview the trimmed strip live, and upscale to carousel width as lossless WebP on macOS.

No npm. The server is Go (`cmd/motif-editor`), same as other repo tools.

## Quick start

From the repo root:

```bash
make motif-editor
```

Or:

```bash
go run ./cmd/motif-editor
```

Open [http://localhost:3847](http://localhost:3847) in Chrome.

Flags: `-addr`, `-app`, `-tmp`, `-realesrgan`, `-model`. Environment: `REALESRGAN_BIN`, `REALESRGAN_MODEL`, `MOTIF_EDITOR_PORT` is not used (use `-addr`).

## Workflow

1. Upload a generated motif image (drag-drop or file picker).
2. Paint **preserve** regions with the brush (white on the internal mask).
3. Erase mistakes with the eraser.
4. Optional: **Wand** click to flood-fill similar colors.
5. Preview updates live as you paint (trim runs automatically).
6. **Upscale** to seamless panorama width (`slides × 600` px at default studio export size; 5px gaps removed automatically). Example: 7 slides → 4200px from a 4230px studio panorama.

Keyboard shortcuts: `B` brush, `E` eraser, `W` wand, `[` / `]` brush size, `Ctrl/Cmd+Z` undo, `Space` + drag pan, scroll zoom.

## Mask model

- Internal mask canvas: white = preserve, black = discard.
- Masking uses canvas `destination-in` so only preserved pixels remain visible.
- Mask PNG save/load removed from UI; use brush, eraser, wand, undo/redo.

## Real-ESRGAN (optional upscale)

The browser cannot run Real-ESRGAN directly. `cmd/motif-editor` shells out to `realesrgan-ncnn-vulkan` on `POST /api/upscale`.

Use the **ncnn-vulkan CLI**, not the Python [Real-ESRGAN](https://github.com/xinntao/Real-ESRGAN) repo.

### macOS install (Apple Silicon and Intel)

**Important:** Do **not** use the large portable zip from the main [Real-ESRGAN releases](https://github.com/xinntao/Real-ESRGAN/releases) (`realesrgan-ncnn-vulkan-20220424-macos.zip`). That binary often **segfaults** on recent macOS (Ventura+, Apple Silicon). Use the smaller **v0.2.0 macOS binary** from [Real-ESRGAN-ncnn-vulkan releases](https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan/releases) plus a `models/` folder.

1. **Vulkan (Apple Silicon):** install MoltenVK so the ncnn binary can use the GPU:

   ```bash
   brew install molten-vk vulkan-loader vulkan-tools
   mkdir -p ~/.local/share/vulkan/icd.d
   ln -sf "$(brew --prefix molten-vk)/share/vulkan/icd.d/MoltenVK_icd.json" \
     ~/.local/share/vulkan/icd.d/
   ```

   Optional check: `vulkaninfo | grep "GPU id" -m1` should show your Apple GPU.

2. **Models** (if you do not already have them). Download the Ubuntu portable zip and extract only `models/`:

   ```bash
   curl -L -o /tmp/realesrgan-models.zip \
     https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesrgan-ncnn-vulkan-20220424-ubuntu.zip
   mkdir -p ~/.local/share/realesrgan-ncnn-vulkan/models
   unzip -j /tmp/realesrgan-models.zip "models/*" \
     -d ~/.local/share/realesrgan-ncnn-vulkan/models
   ```

3. **Binary (v0.2.0 macOS build):**

   ```bash
   curl -L -o /tmp/realesrgan-v020-macos.zip \
     https://github.com/xinntao/Real-ESRGAN-ncnn-vulkan/releases/download/v0.2.0/realesrgan-ncnn-vulkan-v0.2.0-macos.zip
   unzip -o /tmp/realesrgan-v020-macos.zip -d /tmp/realesrgan-v020
   mkdir -p ~/.local/share/realesrgan-ncnn-vulkan ~/.local/bin
   cp /tmp/realesrgan-v020/realesrgan-ncnn-vulkan-v0.2.0-macos/realesrgan-ncnn-vulkan \
     ~/.local/share/realesrgan-ncnn-vulkan/realesrgan-ncnn-vulkan
   chmod +x ~/.local/share/realesrgan-ncnn-vulkan/realesrgan-ncnn-vulkan
   ln -sf ~/.local/share/realesrgan-ncnn-vulkan/realesrgan-ncnn-vulkan \
     ~/.local/bin/realesrgan-ncnn-vulkan
   ```

   Note: the zip unpacks into `realesrgan-ncnn-vulkan-v0.2.0-macos/` (not the zip root).

4. **Gatekeeper:** clear quarantine on downloaded files:

   ```bash
   xattr -dr com.apple.quarantine ~/.local/share/realesrgan-ncnn-vulkan
   ```

   If macOS still blocks the first run, use **System Settings → Privacy & Security → Open Anyway**.

5. **PATH:** ensure `~/.local/bin` is on your PATH. The motif editor also auto-detects `~/.local/bin/realesrgan-ncnn-vulkan` when `REALESRGAN_BIN` is unset.

6. **Optional override:**

   ```bash
   export REALESRGAN_BIN="$HOME/.local/bin/realesrgan-ncnn-vulkan"
   ```

7. **Smoke test:**

   ```bash
   ~/.local/bin/realesrgan-ncnn-vulkan \
     -m ~/.local/share/realesrgan-ncnn-vulkan/models \
     -i ~/.local/share/realesrgan-ncnn-vulkan/input.jpg \
     -o /tmp/realesrgan-test.png \
     -n realesrgan-x4plus -s 2
   ```

   You should see GPU progress (for example `Apple M2`) and `/tmp/realesrgan-test.png` created. If you have no sample `input.jpg`, use any PNG path.

**Upscale artifacts on wide strips:** Real-ESRGAN-ncnn corrupts very wide, short motif strips (black blobs, vertical slices). Strips under 320px tall with aspect ratio ≥ 5:1 use **width resize only** (no AI pass). Wider art still uses Real-ESRGAN when needed. **Key color** is optional; leave empty to upscale Preview as-is.

### Manual CLI example

```bash
realesrgan-ncnn-vulkan \
  -m ~/.local/share/realesrgan-ncnn-vulkan/models \
  -i input.png -o output.png -n realesrgan-x4plus -s 2
```

### Server flags and environment

| Flag / env | Default | Purpose |
|------------|---------|---------|
| `-addr` | `:3847` | Listen address |
| `-realesrgan` / `REALESRGAN_BIN` | `~/.local/bin/realesrgan-ncnn-vulkan` if present, else `realesrgan-ncnn-vulkan` | Upscale binary |
| `-model` / `REALESRGAN_MODEL` | `realesrgan-x4plus` | Default model |
| `-ffmpeg` / `FFMPEG_BIN` | `ffmpeg` | Resize, colorkey, flatten |
| `-cwebp` / `CWEBP_BIN` | `cwebp` | Lossless WebP export after upscale |
| `-app` | `tools/motif-editor/app` | Static frontend |
| `-tmp` | `tools/motif-editor/tmp` | Temp upscale files |

`POST /api/upscale` accepts multipart field `image` (PNG upload from the browser), `slideCount` (target width = seamless `slideCount × 600` px with panorama gaps stripped), or explicit `targetWidth`. Optional `model`. Response is lossless WebP (`image/webp`) via **cwebp** (preferred) or ffmpeg **libwebp** if present.

Homebrew **ffmpeg** often lacks **libwebp**. Install Google's tools: `brew install webp` (provides **cwebp**).

### Panorama constants (central)

Studio panorama export uses **`PANORAMA_SLIDE_WIDTH_PX` (600)** and **`PANORAMA_GAP_PX` (5)**. Keep these in sync across stacks:

| Constant | JS | Go |
|----------|----|----|
| Panorama slice width | `static/carousel/slide-constants.js` → `PANORAMA_SLIDE_WIDTH_PX` | `internal/carousel/slide.go` → `PanoramaSlideWidthPx` |
| Inter-slide gap | `PANORAMA_GAP_PX` | `PanoramaGapPxDefault` |
| Helpers | `stripSlideGapPx`, `panoramaWidthWithGapsPx`, `motifStripSeamlessWidthPx` | `PanoramaGapPx`, `PanoramaWidthWithGapsPx`, `MotifStripSeamlessWidthPx` |

Carousel **render** canvas remains **1080** px (`CAROUSEL_SLIDE_WIDTH_PX` / `SlideWidthPx`).

Example: 7 slides → panorama **4230** px with gaps → motif upscale **4200** px seamless.

## Project layout

```
cmd/motif-editor/     Go HTTP server + upscale API
tools/motif-editor/
  app/                Static frontend (HTML, CSS, ES modules)
  tmp/                Temp files for upscale (gitignored)
```

No auth, database, cloud services, or Node dependencies.

## Carousel bundle usage

After upscale:

1. Place the transparent WebP in your Hugo post bundle under `motifs/`.
2. Point `carousel.json` `deck.motifStrip.src` at the file.
3. Upscale strip art to **N × 600** px seamless width (N = slide count; gaps removed automatically).
4. If the asset still has a solid backdrop, set `keyColor` and `keyTolerance` in `motifStrip`; otherwise use a pre-keyed transparent WebP.

## Development notes

- Editing uses a scaled viewport; mask and upscale input use **original image resolution**.
- Undo/redo stores mask snapshots (max 40 steps).
- Large images: preview is scaled; upscale input stays full resolution.
