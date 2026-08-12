/**
 * Export, trim, and download helpers.
 */

/**
 * Find bounding box of non-transparent pixels (alpha > threshold).
 *
 * @param {HTMLCanvasElement} canvas
 * @param {number} [threshold]
 * @param {number} [padding]
 * @returns {{ x: number, y: number, width: number, height: number } | null}
 */
export function findAlphaBounds(canvas, threshold = 1, padding = 0) {
  const ctx = canvas.getContext('2d');
  if (!ctx) return null;
  const { width, height } = canvas;
  const data = ctx.getImageData(0, 0, width, height).data;
  let minX = width;
  let minY = height;
  let maxX = -1;
  let maxY = -1;

  for (let y = 0; y < height; y++) {
    for (let x = 0; x < width; x++) {
      const a = data[(y * width + x) * 4 + 3];
      if (a > threshold) {
        if (x < minX) minX = x;
        if (y < minY) minY = y;
        if (x > maxX) maxX = x;
        if (y > maxY) maxY = y;
      }
    }
  }

  if (maxX < minX || maxY < minY) return null;

  const pad = Math.max(0, padding);
  minX = Math.max(0, minX - pad);
  minY = Math.max(0, minY - pad);
  maxX = Math.min(width - 1, maxX + pad);
  maxY = Math.min(height - 1, maxY + pad);

  return {
    x: minX,
    y: minY,
    width: maxX - minX + 1,
    height: maxY - minY + 1,
  };
}

/**
 * @param {HTMLCanvasElement} canvas
 * @param {{ x: number, y: number, width: number, height: number }} bounds
 * @returns {HTMLCanvasElement}
 */
export function cropCanvas(canvas, bounds) {
  const out = document.createElement('canvas');
  out.width = bounds.width;
  out.height = bounds.height;
  const ctx = out.getContext('2d');
  if (!ctx) throw new Error('Could not create crop canvas');
  ctx.drawImage(
    canvas,
    bounds.x,
    bounds.y,
    bounds.width,
    bounds.height,
    0,
    0,
    bounds.width,
    bounds.height,
  );
  return out;
}

/**
 * @param {HTMLCanvasElement} canvas
 * @param {number} [padding]
 * @returns {HTMLCanvasElement}
 */
export function trimTransparentBounds(canvas, padding = 8) {
  const bounds = findAlphaBounds(canvas, 1, padding);
  if (!bounds) return canvas;
  return cropCanvas(canvas, bounds);
}

/**
 * @param {HTMLCanvasElement} canvas
 * @param {number} padding
 * @returns {HTMLCanvasElement}
 */
export function padCanvas(canvas, padding) {
  const pad = Math.max(0, Math.floor(padding));
  if (pad === 0) return canvas;
  const out = document.createElement('canvas');
  out.width = canvas.width + pad * 2;
  out.height = canvas.height + pad * 2;
  const ctx = out.getContext('2d');
  if (!ctx) throw new Error('Could not create pad canvas');
  ctx.drawImage(canvas, pad, pad);
  return out;
}

/**
 * Tight trim to content, then transparent margin on all sides.
 *
 * @param {HTMLCanvasElement} canvas
 * @param {number} [margin]
 * @returns {HTMLCanvasElement}
 */
export function trimAndPad(canvas, margin = 0) {
  const trimmed = trimTransparentBounds(canvas, 0);
  return padCanvas(trimmed, margin);
}

/**
 * @param {string} hex
 * @returns {{ r: number, g: number, b: number }}
 */
export function parseHexRgb(hex) {
  let raw = hex.replace('#', '').trim();
  if (raw.length === 3) {
    raw = raw[0] + raw[0] + raw[1] + raw[1] + raw[2] + raw[2];
  }
  if (raw.length !== 6) return { r: 0, g: 0, b: 0 };
  return {
    r: parseInt(raw.slice(0, 2), 16),
    g: parseInt(raw.slice(2, 4), 16),
    b: parseInt(raw.slice(4, 6), 16),
  };
}

/**
 * Knock out pixels near keyHex (matches carousel motif-strip keying).
 *
 * @param {HTMLCanvasElement} canvas
 * @param {string} keyHex
 * @param {number} [tolerance]
 * @returns {HTMLCanvasElement}
 */
export function applyColorKeyToCanvas(canvas, keyHex, tolerance = 32) {
  const ctx = canvas.getContext('2d');
  if (!ctx) return canvas;
  const { width, height } = canvas;
  const { r: kr, g: kg, b: kb } = parseHexRgb(keyHex);
  const tol = Math.max(0, Math.min(255, tolerance));
  const data = ctx.getImageData(0, 0, width, height);
  for (let i = 0; i < data.data.length; i += 4) {
    const r = data.data[i];
    const g = data.data[i + 1];
    const b = data.data[i + 2];
    if (Math.abs(r - kr) <= tol && Math.abs(g - kg) <= tol && Math.abs(b - kb) <= tol) {
      data.data[i + 3] = 0;
    }
  }
  ctx.putImageData(data, 0, 0);
  return canvas;
}

/**
 * Remove studio panorama inter-slide gaps when width matches panorama export layout.
 *
 * @param {HTMLCanvasElement} canvas
 * @param {number} slideCount
 * @param {number} slideWidth
 * @param {number} gapPx
 * @returns {HTMLCanvasElement}
 */
export function removePanoramaSeparators(canvas, slideCount, slideWidth, gapPx) {
  const n = Math.max(1, Math.floor(Number(slideCount) || 0));
  const gap = Math.max(0, Math.floor(Number(gapPx) || 0));
  const slice = Math.max(1, Math.floor(Number(slideWidth) || 0));
  const seamlessWidth = n * slice;
  const expectedWithGaps = seamlessWidth + (n - 1) * gap;

  if (canvas.width === seamlessWidth) return canvas;
  if (canvas.width !== expectedWithGaps) return canvas;

  const out = document.createElement('canvas');
  out.width = seamlessWidth;
  out.height = canvas.height;
  const ctx = out.getContext('2d');
  if (!ctx) return canvas;

  let dx = 0;
  for (let i = 0; i < n; i++) {
    const sx = i * (slice + gap);
    ctx.drawImage(canvas, sx, 0, slice, canvas.height, dx, 0, slice, canvas.height);
    dx += slice;
  }
  return out;
}

/**
 * @param {Blob} blob
 * @param {string} filename
 */
export function downloadBlob(blob, filename) {
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  a.click();
  URL.revokeObjectURL(url);
}

/**
 * PNG blob for server upscale input (pipeline expects raster upload).
 *
 * @param {HTMLCanvasElement} canvas
 * @returns {Promise<Blob>}
 */
export function canvasToPngBlob(canvas) {
  return new Promise((resolve, reject) => {
    canvas.toBlob((blob) => {
      if (blob) resolve(blob);
      else reject(new Error('Failed to encode PNG'));
    }, 'image/png');
  });
}

/**
 * @param {string} apiUrl
 * @param {Blob} imageBlob
 * @param {{ slideCount?: number, targetWidth?: number, model?: string, keyColor?: string }} options
 * @returns {Promise<{ blob: Blob, mode: string }>}
 */
export async function upscaleViaApi(apiUrl, imageBlob, options = {}) {
  const form = new FormData();
  form.append('image', imageBlob, 'motif.png');
  if (options.slideCount != null) {
    form.append('slideCount', String(options.slideCount));
  }
  if (options.targetWidth != null) {
    form.append('targetWidth', String(options.targetWidth));
  }
  if (options.model) form.append('model', options.model);
  if (options.keyColor) form.append('keyColor', options.keyColor);

  const res = await fetch(apiUrl, { method: 'POST', body: form });
  if (!res.ok) {
    let detail = res.statusText;
    try {
      const json = await res.json();
      if (json.error) detail = json.error;
    } catch {
      /* ignore */
    }
    throw new Error(detail);
  }
  const mode = res.headers.get('X-Upscale-Mode') || '';
  const blob = await res.blob();
  return { blob, mode };
}
