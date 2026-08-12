// Command motif-editor serves the local motif mask editor and optional Real-ESRGAN upscale API.
package main

import (
	"encoding/json"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"flag"

	"github.com/xynova/behaviour-engineering/internal/carousel"
	"github.com/xynova/behaviour-engineering/internal/motifeditor"
)

func main() {
	log.SetFlags(log.LstdFlags | log.Lshortfile)

	addr := flag.String("addr", ":3847", "listen address")
	appDir := flag.String("app", "tools/motif-editor/app", "static app directory")
	carouselDir := flag.String("carousel", "static/carousel", "carousel static assets (slide-constants.js)")
	tmpDir := flag.String("tmp", "tools/motif-editor/tmp", "temp directory for upscale")
	realesrganBin := flag.String("realesrgan", envOr("REALESRGAN_BIN", defaultRealESRGANBin()), "Real-ESRGAN ncnn Vulkan binary")
	defaultModel := flag.String("model", envOr("REALESRGAN_MODEL", "realesrgan-x4plus"), "default Real-ESRGAN model name")
	ffmpegBin := flag.String("ffmpeg", envOr("FFMPEG_BIN", "ffmpeg"), "ffmpeg binary for final width resize")
	cwebpBin := flag.String("cwebp", envOr("CWEBP_BIN", "cwebp"), "cwebp binary for lossless WebP export")
	flag.Parse()

	absApp, err := filepath.Abs(*appDir)
	if err != nil {
		log.Fatalf("app path: %v", err)
	}
	if stat, err := os.Stat(absApp); err != nil || !stat.IsDir() {
		log.Fatalf("app directory not found: %s", absApp)
	}

	absCarousel, err := filepath.Abs(*carouselDir)
	if err != nil {
		log.Fatalf("carousel path: %v", err)
	}
	if stat, err := os.Stat(absCarousel); err != nil || !stat.IsDir() {
		log.Fatalf("carousel directory not found: %s", absCarousel)
	}

	absTmp, err := filepath.Abs(*tmpDir)
	if err != nil {
		log.Fatalf("tmp path: %v", err)
	}
	if err := os.MkdirAll(absTmp, 0o755); err != nil {
		log.Fatalf("create tmp: %v", err)
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/api/config", configHandler())
	mux.HandleFunc("/api/health", healthHandler(*realesrganBin, *ffmpegBin, *cwebpBin))
	mux.HandleFunc("/api/upscale", upscaleHandler(absTmp, *realesrganBin, *defaultModel, *ffmpegBin, *cwebpBin))
	mux.Handle("/static/carousel/", http.StripPrefix("/static/carousel/", http.FileServer(http.Dir(absCarousel))))
	mux.Handle("/", http.FileServer(http.Dir(absApp)))

	host := strings.TrimPrefix(*addr, ":")
	if host == "" {
		host = "3847"
	}
	log.Printf("Motif editor: http://localhost:%s", host)
	log.Printf("App dir: %s", absApp)
	log.Printf("Carousel slide width: %d px", carousel.SlideWidthPx)
	log.Printf("Real-ESRGAN binary: %s", *realesrganBin)

	if err := http.ListenAndServe(*addr, mux); err != nil {
		log.Fatal(err)
	}
}

func configHandler() http.HandlerFunc {
	return func(w http.ResponseWriter, _ *http.Request) {
		writeJSON(w, http.StatusOK, map[string]int{
			"slideWidthPx":         carousel.SlideWidthPx,
			"panoramaSlideWidthPx": carousel.PanoramaSlideWidthPx,
			"panoramaGapPx":        carousel.PanoramaGapPxDefault,
		})
	}
}

func healthHandler(realesrganBin, ffmpegBin, cwebpBin string) http.HandlerFunc {
	return func(w http.ResponseWriter, _ *http.Request) {
		writeJSON(w, http.StatusOK, map[string]any{
			"ok":                  true,
			"realesrganBin":       realesrganBin,
			"realesrganAvailable": motifeditor.BinaryAvailable(realesrganBin),
			"ffmpegBin":           ffmpegBin,
			"ffmpegAvailable":     motifeditor.BinaryAvailable(ffmpegBin),
			"cwebpBin":            cwebpBin,
			"cwebpAvailable":      motifeditor.BinaryAvailable(cwebpBin),
			"panoramaSlideWidthPx": carousel.PanoramaSlideWidthPx,
			"panoramaGapPx":        carousel.PanoramaGapPxDefault,
			"slideWidthPx":         carousel.SlideWidthPx,
		})
	}
}

func upscaleHandler(tmpDir, realesrganBin, defaultModel, ffmpegBin, cwebpBin string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}

		r.Body = http.MaxBytesReader(w, r.Body, 80<<20)
		if err := r.ParseMultipartForm(80 << 20); err != nil {
			jsonError(w, http.StatusBadRequest, "invalid multipart form: "+err.Error())
			return
		}

		file, _, err := r.FormFile("image")
		if err != nil {
			jsonError(w, http.StatusBadRequest, "missing image field")
			return
		}
		defer file.Close()

		targetWidth := 0
		slideCount := 0
		if tw := strings.TrimSpace(r.FormValue("targetWidth")); tw != "" {
			targetWidth, _ = strconv.Atoi(tw)
		}
		if sc := strings.TrimSpace(r.FormValue("slideCount")); sc != "" {
			n, err := strconv.Atoi(sc)
			if err == nil && n > 0 {
				slideCount = n
				targetWidth = carousel.MotifStripWidthPx(n)
			}
		}
		if targetWidth <= 0 {
			jsonError(w, http.StatusBadRequest, "missing slideCount or targetWidth")
			return
		}
		if slideCount > 50 {
			jsonError(w, http.StatusBadRequest, "slideCount exceeds maximum limit of 50")
			return
		}
		if targetWidth > 50000 {
			jsonError(w, http.StatusBadRequest, "targetWidth exceeds maximum limit of 50000px")
			return
		}

		model := strings.TrimSpace(r.FormValue("model"))
		if model == "" {
			model = defaultModel
		}
		keyColor := strings.TrimSpace(r.FormValue("keyColor"))

		tmpFile, err := os.CreateTemp(tmpDir, "upscale-input-*.png")
		if err != nil {
			jsonError(w, http.StatusInternalServerError, "could not create temp input")
			return
		}
		inputPath := tmpFile.Name()
		defer os.Remove(inputPath)
		defer tmpFile.Close()

		outputFile, err := os.CreateTemp(tmpDir, "upscale-output-*.png")
		if err != nil {
			jsonError(w, http.StatusInternalServerError, "could not create temp output")
			return
		}
		outputPath := outputFile.Name()
		outputFile.Close()
		defer os.Remove(outputPath)

		webpFile, err := os.CreateTemp(tmpDir, "upscale-output-*.webp")
		if err != nil {
			jsonError(w, http.StatusInternalServerError, "could not create temp webp")
			return
		}
		webpPath := webpFile.Name()
		webpFile.Close()
		defer os.Remove(webpPath)

		if _, err := io.Copy(tmpFile, file); err != nil {
			jsonError(w, http.StatusInternalServerError, "could not save upload")
			return
		}
		if err := tmpFile.Close(); err != nil {
			jsonError(w, http.StatusInternalServerError, "could not close temp input")
			return
		}

		mode, err := motifeditor.UpscaleToWidth(
			r.Context(),
			realesrganBin, model, ffmpegBin,
			inputPath, outputPath,
			targetWidth,
			slideCount, carousel.PanoramaSlideWidthPx, carousel.PanoramaGapPx(carousel.PanoramaSlideWidthPx),
			keyColor,
		)
		if err != nil {
			jsonError(w, http.StatusInternalServerError, err.Error())
			return
		}

		if err := motifeditor.EncodeWebPFromPNG(r.Context(), ffmpegBin, cwebpBin, outputPath, webpPath); err != nil {
			jsonError(w, http.StatusInternalServerError, err.Error())
			return
		}

		result, err := os.Open(webpPath)
		if err != nil {
			jsonError(w, http.StatusInternalServerError, "upscale produced no output file")
			return
		}
		defer result.Close()

		w.Header().Set("Content-Type", "image/webp")
		w.Header().Set("Content-Disposition", "attachment; filename=\"motif-upscaled.webp\"")
		w.Header().Set("X-Upscale-Mode", mode)
		if _, err := io.Copy(w, result); err != nil {
			log.Printf("write response: %v", err)
		}
	}
}

func writeJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	if err := json.NewEncoder(w).Encode(v); err != nil {
		log.Printf("encode json: %v", err)
	}
}

func jsonError(w http.ResponseWriter, status int, message string) {
	writeJSON(w, status, map[string]string{"error": message})
}

func envOr(key, fallback string) string {
	if v := strings.TrimSpace(os.Getenv(key)); v != "" {
		return v
	}
	return fallback
}

func defaultRealESRGANBin() string {
	home, err := os.UserHomeDir()
	if err != nil {
		return "realesrgan-ncnn-vulkan"
	}
	localBin := filepath.Join(home, ".local", "bin", "realesrgan-ncnn-vulkan")
	if motifeditor.BinaryAvailable(localBin) {
		return localBin
	}
	return "realesrgan-ncnn-vulkan"
}
