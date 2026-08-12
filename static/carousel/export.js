/** WebP quality for slide export (0–1). */
export const EXPORT_WEBP_QUALITY = 0.92;

/**
 * @param {HTMLCanvasElement} canvas
 * @param {string} filename Must end in `.webp` (or any name; MIME is WebP).
 */
export function downloadCanvasWebp(canvas, filename) {
  return new Promise((resolve, reject) => {
    canvas.toBlob(
      (blob) => {
        if (!blob) {
          reject(new Error('Canvas export produced empty blob'));
          return;
        }
        const url = URL.createObjectURL(blob);
        const anchor = document.createElement('a');
        anchor.href = url;
        anchor.download = filename;
        anchor.click();
        setTimeout(() => {
          URL.revokeObjectURL(url);
          resolve(undefined);
        }, 100);
      },
      'image/webp',
      EXPORT_WEBP_QUALITY,
    );
  });
}

/**
 * Variant label for export filenames: 0 → `a`, 1 → `b`, … (26+ → `v27`, …).
 * @param {number} index 0-based index in `slide.variants`
 */
export function variantIdFromIndex(index) {
  const i = Math.max(0, Math.floor(index));
  if (i < 26) {
    return String.fromCharCode(97 + i);
  }
  return `v${i + 1}`;
}

/**
 * @param {string} slug
 * @param {number|string} slideNumber
 * @param {number} variantIndex 0-based index in `slide.variants`
 */
export function exportFilename(slug, slideNumber, variantIndex) {
  const num = String(slideNumber).padStart(2, '0');
  return `${slug}-slide-${num}-${variantIdFromIndex(variantIndex)}.webp`;
}

/**
 * @param {string} slug
 */
export function exportStripFilename(slug) {
  return `${slug}-panorama.webp`;
}
