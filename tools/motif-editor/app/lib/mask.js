/**
 * Mask canvas utilities: preserve (white) vs discard (black).
 */

/**
 * @param {number} width
 * @param {number} height
 * @returns {{ canvas: HTMLCanvasElement, ctx: CanvasRenderingContext2D }}
 */
export function createMaskCanvas(width, height) {
  const canvas = document.createElement('canvas');
  canvas.width = width;
  canvas.height = height;
  const ctx = canvas.getContext('2d', { willReadFrequently: true });
  if (!ctx) throw new Error('Could not create mask canvas context');
  ctx.fillStyle = '#000000';
  ctx.fillRect(0, 0, width, height);
  return { canvas, ctx };
}

/**
 * @param {CanvasRenderingContext2D} maskCtx
 * @param {number} x Image-space x
 * @param {number} y Image-space y
 * @param {number} radius Brush radius in image pixels
 * @param {'brush' | 'eraser'} mode
 * @param {number} hardness 0 (soft) to 1 (hard)
 */
export function paintStroke(maskCtx, x, y, radius, mode, hardness = 1) {
  maskCtx.globalCompositeOperation = 'source-over';
  maskCtx.globalAlpha = 1;
  const color = mode === 'brush' ? '#ffffff' : '#000000';
  if (hardness >= 0.95) {
    maskCtx.fillStyle = color;
    maskCtx.beginPath();
    maskCtx.arc(x, y, radius, 0, Math.PI * 2);
    maskCtx.fill();
    return;
  }

  const gradient = maskCtx.createRadialGradient(x, y, 0, x, y, radius);
  const inner = Math.max(0, hardness);
  gradient.addColorStop(0, color);
  gradient.addColorStop(inner, color);
  gradient.addColorStop(1, mode === 'brush' ? 'rgba(255,255,255,0)' : 'rgba(0,0,0,0)');
  maskCtx.fillStyle = gradient;
  maskCtx.beginPath();
  maskCtx.arc(x, y, radius, 0, Math.PI * 2);
  maskCtx.fill();
}

/**
 * Convert grayscale preserve mask (white = keep) to an alpha-only canvas for compositing.
 *
 * @param {HTMLCanvasElement} maskCanvas
 * @param {number} [featherPx]
 * @returns {HTMLCanvasElement}
 */
export function maskToAlphaCanvas(maskCanvas, featherPx = 0) {
  const w = maskCanvas.width;
  const h = maskCanvas.height;
  const tmp = document.createElement('canvas');
  tmp.width = w;
  tmp.height = h;
  const tctx = tmp.getContext('2d');
  if (!tctx) throw new Error('Could not create mask alpha temp');

  if (featherPx > 0) {
    tctx.filter = `blur(${featherPx}px)`;
  }
  tctx.drawImage(maskCanvas, 0, 0);
  tctx.filter = 'none';

  const data = tctx.getImageData(0, 0, w, h);
  const alpha = document.createElement('canvas');
  alpha.width = w;
  alpha.height = h;
  const actx = alpha.getContext('2d');
  if (!actx) throw new Error('Could not create mask alpha canvas');
  const alphaData = actx.createImageData(w, h);

  for (let i = 0; i < data.data.length; i += 4) {
    const lum = Math.round(data.data[i] * data.data[i + 3] / 255);
    alphaData.data[i] = 255;
    alphaData.data[i + 1] = 255;
    alphaData.data[i + 2] = 255;
    alphaData.data[i + 3] = lum;
  }
  actx.putImageData(alphaData, 0, 0);
  return alpha;
}

/**
 * Apply preserve mask to source image using destination-in compositing.
 *
 * @param {HTMLImageElement | HTMLCanvasElement} source
 * @param {HTMLCanvasElement} maskCanvas White = preserve, black = discard
 * @param {number} [featherPx] Optional blur on mask before apply
 * @returns {HTMLCanvasElement}
 */
export function applyMask(source, maskCanvas, featherPx = 0) {
  const w = source.width;
  const h = source.height;
  const out = document.createElement('canvas');
  out.width = w;
  out.height = h;
  const ctx = out.getContext('2d');
  if (!ctx) throw new Error('Could not create output canvas');

  const alphaMask = maskToAlphaCanvas(maskCanvas, featherPx);

  ctx.drawImage(source, 0, 0, w, h);
  ctx.globalCompositeOperation = 'destination-in';
  ctx.drawImage(alphaMask, 0, 0, w, h);
  ctx.globalCompositeOperation = 'source-over';
  return out;
}

/**
 * Invert mask (swap preserve and discard).
 *
 * @param {HTMLCanvasElement} maskCanvas
 */
export function invertMask(maskCanvas) {
  const ctx = maskCanvas.getContext('2d');
  if (!ctx) return;
  const { width, height } = maskCanvas;
  const data = ctx.getImageData(0, 0, width, height);
  for (let i = 0; i < data.data.length; i += 4) {
    data.data[i] = 255 - data.data[i];
    data.data[i + 1] = 255 - data.data[i + 1];
    data.data[i + 2] = 255 - data.data[i + 2];
  }
  ctx.putImageData(data, 0, 0);
}

/**
 * @param {HTMLCanvasElement} maskCanvas
 */
export function resetMask(maskCanvas) {
  const ctx = maskCanvas.getContext('2d');
  if (!ctx) return;
  ctx.fillStyle = '#000000';
  ctx.fillRect(0, 0, maskCanvas.width, maskCanvas.height);
}

/**
 * @param {HTMLCanvasElement} canvas
 * @returns {ImageData}
 */
export function snapshotCanvas(canvas) {
  const ctx = canvas.getContext('2d');
  if (!ctx) throw new Error('No context');
  return ctx.getImageData(0, 0, canvas.width, canvas.height);
}

/**
 * @param {HTMLCanvasElement} canvas
 * @param {ImageData} data
 */
export function restoreSnapshot(canvas, data) {
  const ctx = canvas.getContext('2d');
  if (!ctx) return;
  ctx.putImageData(data, 0, 0);
}

/**
 * Seed mask from existing image alpha (for already-transparent assets).
 *
 * @param {HTMLCanvasElement} maskCanvas
 * @param {HTMLImageElement | HTMLCanvasElement} source
 */
export function seedMaskFromAlpha(maskCanvas, source) {
  const w = source.width;
  const h = source.height;
  const tmp = document.createElement('canvas');
  tmp.width = w;
  tmp.height = h;
  const tctx = tmp.getContext('2d');
  if (!tctx) return;
  tctx.drawImage(source, 0, 0);
  const alpha = tctx.getImageData(0, 0, w, h);
  const maskCtx = maskCanvas.getContext('2d');
  if (!maskCtx) return;
  const maskData = maskCtx.createImageData(w, h);
  for (let i = 0; i < alpha.data.length; i += 4) {
    const a = alpha.data[i + 3];
    const v = a > 16 ? 255 : 0;
    maskData.data[i] = v;
    maskData.data[i + 1] = v;
    maskData.data[i + 2] = v;
    maskData.data[i + 3] = 255;
  }
  maskCtx.putImageData(maskData, 0, 0);
}

/**
 * Flood-fill preserve region from a seed color (magic wand seed).
 *
 * @param {HTMLCanvasElement} maskCanvas
 * @param {HTMLImageElement | HTMLCanvasElement} source
 * @param {number} sx Image x
 * @param {number} sy Image y
 * @param {number} tolerance Per-channel tolerance (0-255)
 */
export function floodFillPreserve(maskCanvas, source, sx, sy, tolerance = 32) {
  const w = source.width;
  const h = source.height;
  const tmp = document.createElement('canvas');
  tmp.width = w;
  tmp.height = h;
  const tctx = tmp.getContext('2d');
  if (!tctx) return;
  tctx.drawImage(source, 0, 0);
  const img = tctx.getImageData(0, 0, w, h);
  const ix = Math.floor(sx);
  const iy = Math.floor(sy);
  if (ix < 0 || iy < 0 || ix >= w || iy >= h) return;

  const start = (iy * w + ix) * 4;
  const sr = img.data[start];
  const sg = img.data[start + 1];
  const sb = img.data[start + 2];
  const sa = img.data[start + 3];
  if (sa < 8) return;

  const visited = new Uint8Array(w * h);
  const stack = [];
  const maskCtx = maskCanvas.getContext('2d');
  if (!maskCtx) return;
  const maskData = maskCtx.getImageData(0, 0, w, h);

  const matches = (i) => {
    const dr = Math.abs(img.data[i] - sr);
    const dg = Math.abs(img.data[i + 1] - sg);
    const db = Math.abs(img.data[i + 2] - sb);
    const da = Math.abs(img.data[i + 3] - sa);
    return dr <= tolerance && dg <= tolerance && db <= tolerance && da <= tolerance;
  };

  const push = (x, y) => {
    if (x < 0 || y < 0 || x >= w || y >= h) return;
    const idx = y * w + x;
    if (visited[idx]) return;
    const pi = idx * 4;
    if (!matches(pi)) return;
    visited[idx] = 1;
    stack.push(x, y);
  };

  push(ix, iy);

  while (stack.length) {
    const y = stack.pop();
    const x = stack.pop();
    const idx = y * w + x;
    const pi = idx * 4;
    maskData.data[pi] = 255;
    maskData.data[pi + 1] = 255;
    maskData.data[pi + 2] = 255;
    maskData.data[pi + 3] = 255;

    push(x + 1, y);
    push(x - 1, y);
    push(x, y + 1);
    push(x, y - 1);
  }
  maskCtx.putImageData(maskData, 0, 0);
}
