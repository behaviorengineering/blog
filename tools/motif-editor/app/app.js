import {
  createMaskCanvas,
  paintStroke,
  applyMask,
  snapshotCanvas,
  restoreSnapshot,
  floodFillPreserve,
} from './lib/mask.js';
import {
  trimTransparentBounds,
  applyColorKeyToCanvas,
  removePanoramaSeparators,
  downloadBlob,
  canvasToPngBlob,
  upscaleViaApi,
  findAlphaBounds,
} from './lib/export.js';
import {
  panoramaSlideWidthPx,
  panoramaGapPx,
  applyPanoramaConfig,
  motifStripSeamlessWidthPx,
  panoramaWidthWithGapsPx,
} from './lib/panorama-config.js';

/** @typedef {'brush' | 'eraser' | 'wand'} ToolMode */

const MAX_UNDO = 40;
const SLIDE_COUNT_STORAGE_KEY = 'motif-editor-slide-count';

/** @type {number} */
let panoramaSlideWidth = panoramaSlideWidthPx;
/** @type {number} */
let panoramaGap = panoramaGapPx;
/** @type {number} */
let viewWidth = 1;
/** @type {number} */
let viewHeight = 1;
/** @type {number | null} */
let activePointerId = null;
/** @type {Map<number, { x: number, y: number }>} */
const pointerPositions = new Map();
let pinchRefDistance = 0;
let pinchRefZoom = 1;

const editCanvas = /** @type {HTMLCanvasElement} */ (document.getElementById('edit-canvas'));
const previewCanvas = /** @type {HTMLCanvasElement} */ (document.getElementById('preview-canvas'));
const editWrap = document.getElementById('edit-wrap');
const fileInput = /** @type {HTMLInputElement} */ (document.getElementById('file-input'));
const sourceInfo = document.getElementById('source-info');
const previewInfo = document.getElementById('preview-info');
const statusEl = document.getElementById('status');

/** @type {HTMLImageElement | null} */
let sourceImage = null;
/** @type {HTMLCanvasElement | null} */
let maskCanvas = null;
/** @type {string} */
let sourceFilename = 'motif.webp';

let previewUpdateScheduled = false;

let keyColorEnabled = false;
/** @type {string} */
let keyColorValue = '#013231';

let zoom = 1;
let panX = 0;
let panY = 0;
/** @type {ToolMode} */
let toolMode = 'brush';
let isDrawing = false;
let isPanning = false;
let spaceHeld = false;
let lastImageX = 0;
let lastImageY = 0;
/** @type {number | null} */
let hoverImageX = null;
/** @type {number | null} */
let hoverImageY = null;
/** @type {ImageData[]} */
let undoStack = [];
/** @type {ImageData[]} */
let redoStack = [];

function setStatus(text, kind = '') {
  statusEl.textContent = text;
  statusEl.className = 'header-status status' + (kind ? ` ${kind}` : '');
}

function getBrushSize() {
  return Number(document.getElementById('brush-size').value);
}

function getBrushHardness() {
  return Number(document.getElementById('brush-hardness').value) / 100;
}

function getFeather() {
  return Number(document.getElementById('feather').value);
}

/**
 * Masked output trimmed for export / upscale.
 *
 * @returns {HTMLCanvasElement | null}
 */
function buildExportCanvas() {
  if (!sourceImage || !maskCanvas) return null;
  return trimTransparentBounds(applyMask(sourceImage, maskCanvas, getFeather()), 0);
}

function buildPreviewCanvas() {
  let base = buildExportCanvas();
  if (!base) return null;
  base = removePanoramaSeparators(base, getSlideCount(), panoramaSlideWidth, panoramaGap);
  const keyColor = getUpscaleKeyColor();
  if (!keyColor) return base;

  const out = document.createElement('canvas');
  out.width = base.width;
  out.height = base.height;
  const ctx = out.getContext('2d');
  if (!ctx) return base;
  ctx.drawImage(base, 0, 0);
  applyColorKeyToCanvas(out, keyColor);
  return trimTransparentBounds(out, 0);
}

function schedulePreviewUpdate() {
  if (previewUpdateScheduled) return;
  previewUpdateScheduled = true;
  requestAnimationFrame(() => {
    previewUpdateScheduled = false;
    renderPreviewCanvas();
  });
}

function getUpscaleKeyColor() {
  return keyColorEnabled ? keyColorValue : '';
}

function normalizeHexColor(value) {
  const trimmed = value.trim();
  if (!/^#[0-9a-fA-F]{6}$/.test(trimmed)) return null;
  return trimmed.toLowerCase();
}

function updateKeyColorPreview() {
  const swatch = document.getElementById('key-color-swatch');
  const hexEl = document.getElementById('key-color-hex');
  const picker = /** @type {HTMLInputElement | null} */ (document.getElementById('upscale-key-color-picker'));
  const clearBtn = /** @type {HTMLButtonElement | null} */ (document.getElementById('btn-key-color-clear'));
  if (!swatch || !hexEl || !picker) return;

  if (keyColorEnabled) {
    swatch.classList.remove('is-empty');
    swatch.style.backgroundColor = keyColorValue;
    hexEl.textContent = keyColorValue;
    hexEl.classList.remove('is-none');
    picker.value = keyColorValue;
    if (clearBtn) clearBtn.disabled = false;
  } else {
    swatch.classList.add('is-empty');
    swatch.style.backgroundColor = '';
    hexEl.textContent = 'None';
    hexEl.classList.add('is-none');
    if (clearBtn) clearBtn.disabled = true;
  }
}

function openKeyColorPicker() {
  const picker = /** @type {HTMLInputElement | null} */ (document.getElementById('upscale-key-color-picker'));
  if (!picker) return;
  if (typeof picker.showPicker === 'function') {
    picker.showPicker();
    return;
  }
  picker.click();
}

function handleKeyColorPick() {
  const picker = /** @type {HTMLInputElement | null} */ (document.getElementById('upscale-key-color-picker'));
  if (!picker) return;
  const next = normalizeHexColor(picker.value);
  if (!next) return;
  keyColorEnabled = true;
  keyColorValue = next;
  updateKeyColorPreview();
  schedulePreviewUpdate();
}

function initKeyColorPicker() {
  const picker = /** @type {HTMLInputElement | null} */ (document.getElementById('upscale-key-color-picker'));
  const openBtn = /** @type {HTMLButtonElement | null} */ (document.getElementById('btn-key-color-open'));
  const clearBtn = /** @type {HTMLButtonElement | null} */ (document.getElementById('btn-key-color-clear'));
  if (!picker) return;

  openBtn?.addEventListener('click', () => {
    openKeyColorPicker();
  });

  picker.addEventListener('input', handleKeyColorPick);
  picker.addEventListener('change', handleKeyColorPick);

  clearBtn?.addEventListener('click', () => {
    keyColorEnabled = false;
    updateKeyColorPreview();
    schedulePreviewUpdate();
  });

  updateKeyColorPreview();
}

function getSlideCount() {
  const el = /** @type {HTMLInputElement} */ (document.getElementById('slide-count'));
  return Math.max(1, Math.floor(Number(el.value) || 0));
}

function getCarouselTargetWidth() {
  return motifStripSeamlessWidthPx(getSlideCount(), panoramaSlideWidth);
}

function updateTargetWidthLabel() {
  const slides = getSlideCount();
  const target = getCarouselTargetWidth();
  const withGaps = panoramaWidthWithGapsPx(slides, panoramaSlideWidth);
  const label = document.getElementById('target-width-label');
  if (label) {
    label.textContent = `Upscale: ${slides} × ${panoramaSlideWidth}px = ${target}px (gaps removed; studio panorama is ${withGaps}px)`;
  }
}

async function initCarouselConfig() {
  try {
    const res = await fetch('/api/config');
    if (res.ok) {
      applyPanoramaConfig(await res.json());
      panoramaSlideWidth = panoramaSlideWidthPx;
      panoramaGap = panoramaGapPx;
    }
  } catch {
    /* use defaults from slide-constants.js */
  }
  const stored = localStorage.getItem(SLIDE_COUNT_STORAGE_KEY);
  const slideInput = /** @type {HTMLInputElement} */ (document.getElementById('slide-count'));
  if (stored && slideInput) {
    slideInput.value = stored;
  }
  updateTargetWidthLabel();
}

function getOverlayMode() {
  return /** @type {HTMLSelectElement} */ (document.getElementById('overlay-mode')).value;
}

function getMaskOverlayOpacity() {
  return Number(document.getElementById('mask-opacity').value) / 100;
}

function updateBrushLabel() {
  document.getElementById('brush-size-label').textContent = String(getBrushSize());
}

function pushUndo() {
  if (!maskCanvas) return false;
  try {
    undoStack.push(snapshotCanvas(maskCanvas));
  } catch {
    setStatus('Could not save undo step (mask too large).', 'error');
    return false;
  }
  if (undoStack.length > MAX_UNDO) undoStack.shift();
  redoStack = [];
  return true;
}

function undo() {
  if (!maskCanvas || undoStack.length === 0) return;
  redoStack.push(snapshotCanvas(maskCanvas));
  const prev = undoStack.pop();
  if (prev) restoreSnapshot(maskCanvas, prev);
  renderEditCanvas();
  schedulePreviewUpdate();
}

function redo() {
  if (!maskCanvas || redoStack.length === 0) return;
  undoStack.push(snapshotCanvas(maskCanvas));
  const next = redoStack.pop();
  if (next) restoreSnapshot(maskCanvas, next);
  renderEditCanvas();
  schedulePreviewUpdate();
}

function fitToView() {
  if (!sourceImage || !editWrap) return;
  syncEditCanvasSize();
  const scaleX = viewWidth / sourceImage.width;
  const scaleY = viewHeight / sourceImage.height;
  zoom = Math.min(scaleX, scaleY) * 0.92;
  panX = (viewWidth - sourceImage.width * zoom) / 2;
  panY = (viewHeight - sourceImage.height * zoom) / 2;
  renderEditCanvas();
}

/** Match canvas bitmap to the edit wrap inner size. */
function syncEditCanvasSize() {
  if (!editWrap) return;
  viewWidth = Math.max(1, editWrap.clientWidth);
  viewHeight = Math.max(1, editWrap.clientHeight);
  if (editCanvas.width !== viewWidth || editCanvas.height !== viewHeight) {
    editCanvas.width = viewWidth;
    editCanvas.height = viewHeight;
  }
  editCanvas.style.width = `${viewWidth}px`;
  editCanvas.style.height = `${viewHeight}px`;
}

function screenToImage(clientX, clientY) {
  const rect = editCanvas.getBoundingClientRect();
  const scaleX = rect.width > 0 ? editCanvas.width / rect.width : 1;
  const scaleY = rect.height > 0 ? editCanvas.height / rect.height : 1;
  const cx = (clientX - rect.left) * scaleX;
  const cy = (clientY - rect.top) * scaleY;
  return {
    x: (cx - panX) / zoom,
    y: (cy - panY) / zoom,
  };
}

function clampToImage(x, y) {
  if (!sourceImage) return { x, y };
  return {
    x: Math.max(0, Math.min(sourceImage.width, x)),
    y: Math.max(0, Math.min(sourceImage.height, y)),
  };
}

function pinchDistance() {
  const pts = [...pointerPositions.values()];
  if (pts.length < 2) return 0;
  return Math.hypot(pts[0].x - pts[1].x, pts[0].y - pts[1].y);
}

function pinchCenterClient() {
  const pts = [...pointerPositions.values()];
  if (pts.length < 2) return { x: 0, y: 0 };
  return {
    x: (pts[0].x + pts[1].x) / 2,
    y: (pts[0].y + pts[1].y) / 2,
  };
}

function zoomAtClient(clientX, clientY, factor) {
  const before = screenToImage(clientX, clientY);
  zoom = Math.max(0.05, Math.min(20, zoom * factor));
  const after = screenToImage(clientX, clientY);
  panX += (after.x - before.x) * zoom;
  panY += (after.y - before.y) * zoom;
  renderEditCanvas();
}

function startPinchReference() {
  pinchRefDistance = pinchDistance();
  pinchRefZoom = zoom;
}

function renderEditCanvas() {
  const ctx = editCanvas.getContext('2d');
  if (!ctx) return;
  syncEditCanvasSize();

  ctx.clearRect(0, 0, editCanvas.width, editCanvas.height);
  if (!sourceImage) return;

  const w = sourceImage.width;
  const h = sourceImage.height;
  const overlay = getOverlayMode();

  ctx.save();
  ctx.translate(panX, panY);
  ctx.scale(zoom, zoom);

  if (overlay === 'image' || overlay === 'both') {
    ctx.drawImage(sourceImage, 0, 0);
  }

  if (maskCanvas && (overlay === 'mask' || overlay === 'both')) {
    if (overlay === 'mask') {
      ctx.fillStyle = '#111';
      ctx.fillRect(0, 0, w, h);
      ctx.drawImage(maskCanvas, 0, 0);
    } else {
      const tint = buildMaskTintCanvas(w, h, getMaskOverlayOpacity());
      if (tint) ctx.drawImage(tint, 0, 0);
    }
  }

  ctx.restore();
  drawBrushPreview(ctx);
}

/** Brush / eraser size ring in image space. */
function drawBrushPreview(ctx) {
  if (hoverImageX == null || hoverImageY == null || toolMode === 'wand' || isPanning) return;
  if (!sourceImage) return;
  const radius = getBrushSize() / 2;
  ctx.save();
  ctx.translate(panX, panY);
  ctx.scale(zoom, zoom);
  ctx.beginPath();
  ctx.arc(hoverImageX, hoverImageY, radius, 0, Math.PI * 2);
  ctx.strokeStyle = toolMode === 'eraser'
    ? 'rgba(255, 120, 120, 0.9)'
    : 'rgba(120, 220, 150, 0.9)';
  ctx.lineWidth = Math.max(1.5, 2 / zoom);
  ctx.setLineDash([6 / zoom, 4 / zoom]);
  ctx.stroke();
  ctx.restore();
}

/**
 * Green tint only on preserve (white) mask pixels; does not replace underlying image.
 *
 * @param {number} width
 * @param {number} height
 * @param {number} opacity
 * @returns {HTMLCanvasElement | null}
 */
function buildMaskTintCanvas(width, height, opacity) {
  if (!maskCanvas) return null;
  const mctx = maskCanvas.getContext('2d');
  if (!mctx) return null;
  const maskData = mctx.getImageData(0, 0, width, height);

  const tint = document.createElement('canvas');
  tint.width = width;
  tint.height = height;
  const tctx = tint.getContext('2d');
  if (!tctx) return null;
  const tintData = tctx.createImageData(width, height);
  const o = Math.max(0, Math.min(1, opacity));

  for (let i = 0; i < maskData.data.length; i += 4) {
    const lum = Math.round(maskData.data[i] * maskData.data[i + 3] / 255);
    if (lum < 1) continue;
    tintData.data[i] = 100;
    tintData.data[i + 1] = 200;
    tintData.data[i + 2] = 120;
    tintData.data[i + 3] = Math.round(lum * o);
  }
  tctx.putImageData(tintData, 0, 0);
  return tint;
}

function renderPreviewCanvas() {
  const ctx = previewCanvas.getContext('2d');
  if (!ctx) return;
  const wrap = document.getElementById('preview-wrap');
  if (!wrap) return;
  const w = Math.max(1, wrap.clientWidth);
  const h = Math.max(1, wrap.clientHeight);
  if (previewCanvas.width !== w || previewCanvas.height !== h) {
    previewCanvas.width = w;
    previewCanvas.height = h;
  }
  previewCanvas.style.width = `${w}px`;
  previewCanvas.style.height = `${h}px`;
  ctx.clearRect(0, 0, previewCanvas.width, previewCanvas.height);

  if (!sourceImage || !maskCanvas) {
    previewInfo.textContent = 'Live upscale preview';
    return;
  }

  const exportCanvas = buildPreviewCanvas();
  if (!exportCanvas) {
    previewInfo.textContent = 'Live upscale preview';
    return;
  }

  const bounds = findAlphaBounds(exportCanvas);
  if (!bounds) {
    previewInfo.textContent = getUpscaleKeyColor()
      ? 'Paint preserve regions; key color removes matching backdrop'
      : 'Paint preserve regions to preview upscale input';
    return;
  }

  const scale = Math.min(
    previewCanvas.width / exportCanvas.width,
    previewCanvas.height / exportCanvas.height,
  ) * 0.92;
  const dw = exportCanvas.width * scale;
  const dh = exportCanvas.height * scale;
  const dx = (previewCanvas.width - dw) / 2;
  const dy = (previewCanvas.height - dh) / 2;
  ctx.drawImage(exportCanvas, dx, dy, dw, dh);

  previewInfo.textContent = bounds
    ? `Upscale input ${exportCanvas.width} × ${exportCanvas.height}px (content ${bounds.width} × ${bounds.height})${getUpscaleKeyColor() ? ` · key ${getUpscaleKeyColor()}` : ''}`
    : `Upscale input ${exportCanvas.width} × ${exportCanvas.height}px${getUpscaleKeyColor() ? ` · key ${getUpscaleKeyColor()}` : ''}`;
}

function paintAtImageCoords(ix, iy) {
  if (!maskCanvas || !sourceImage) return;
  const maskCtx = maskCanvas.getContext('2d');
  if (!maskCtx) return;
  const clamped = clampToImage(ix, iy);
  ix = clamped.x;
  iy = clamped.y;
  const radius = getBrushSize() / 2;
  const hardness = getBrushHardness();
  const mode = toolMode === 'eraser' ? 'eraser' : 'brush';

  const dx = ix - lastImageX;
  const dy = iy - lastImageY;
  const dist = Math.hypot(dx, dy);
  const step = Math.max(1, radius / 4);
  if (dist > step) {
    const steps = Math.ceil(dist / step);
    for (let i = 1; i <= steps; i++) {
      const t = i / steps;
      paintStroke(
        maskCtx,
        lastImageX + dx * t,
        lastImageY + dy * t,
        radius,
        mode,
        hardness,
      );
    }
  } else {
    paintStroke(maskCtx, ix, iy, radius, mode, hardness);
  }
  lastImageX = ix;
  lastImageY = iy;
  renderEditCanvas();
  schedulePreviewUpdate();
}

async function upscaleCarouselAction() {
  const canvas = buildExportCanvas();
  if (!canvas || !findAlphaBounds(canvas)) {
    setStatus('Nothing to upscale. Paint preserve regions first.', 'error');
    return;
  }
  const slideCount = getSlideCount();
  const targetWidth = getCarouselTargetWidth();
  localStorage.setItem(SLIDE_COUNT_STORAGE_KEY, String(slideCount));
  setStatus(`Upscaling ${canvas.width}×${canvas.height}px → ${targetWidth}px wide...`);
  try {
    const blob = await canvasToPngBlob(canvas);
    const { blob: result, mode } = await upscaleViaApi('/api/upscale', blob, {
      slideCount,
      keyColor: getUpscaleKeyColor(),
    });
    const base = sourceFilename.replace(/\.[^.]+$/, '') || 'motif';
    downloadBlob(result, `${base}-motif-${targetWidth}w.webp`);
    if (mode === 'width-resize') {
      setStatus(
        `Upscale complete: ${targetWidth}px wide (width resize; strip too thin for a safe AI pass).`,
        'ok',
      );
    } else {
      setStatus(`Upscale complete: ${targetWidth}px wide (${canvas.width}×${canvas.height} input).`, 'ok');
    }
  } catch (err) {
    setStatus(err instanceof Error ? err.message : String(err), 'error');
  }
}

function loadImageFromFile(file) {
  const url = URL.createObjectURL(file);
  const img = new Image();
  img.onload = () => {
    URL.revokeObjectURL(url);
    sourceImage = img;
    sourceFilename = file.name || 'motif.webp';
    const { canvas } = createMaskCanvas(img.width, img.height);
    maskCanvas = canvas;
    undoStack = [];
    redoStack = [];
    sourceInfo.textContent = `${sourceFilename} · ${img.width} × ${img.height}px`;
    fitToView();
    schedulePreviewUpdate();
    setStatus('Image loaded. Paint preserve regions on the motif.', 'ok');
  };
  img.onerror = () => {
    URL.revokeObjectURL(url);
    setStatus('Failed to load image.', 'error');
  };
  img.src = url;
}

function setToolMode(mode) {
  toolMode = mode;
  document.getElementById('btn-brush').classList.toggle('active', mode === 'brush');
  document.getElementById('btn-eraser').classList.toggle('active', mode === 'eraser');
  document.getElementById('btn-wand').classList.toggle('active', mode === 'wand');
  editWrap.classList.remove('tool-brush', 'tool-eraser', 'tool-wand');
  editWrap.classList.add(`tool-${mode}`);
  const labels = { brush: 'Brush', eraser: 'Eraser', wand: 'Wand (click to fill)' };
  setStatus(`${labels[mode]} · size ${getBrushSize()}px`, 'ok');
  renderEditCanvas();
}

// Events
fileInput.addEventListener('change', () => {
  const file = fileInput.files?.[0];
  if (file) loadImageFromFile(file);
  fileInput.value = '';
});

document.getElementById('btn-brush').addEventListener('click', () => setToolMode('brush'));
document.getElementById('btn-eraser').addEventListener('click', () => setToolMode('eraser'));
document.getElementById('btn-wand').addEventListener('click', () => setToolMode('wand'));

document.getElementById('brush-size').addEventListener('input', () => {
  updateBrushLabel();
  setStatus(`Brush size ${getBrushSize()}px`, 'ok');
  renderEditCanvas();
});
document.getElementById('overlay-mode').addEventListener('change', renderEditCanvas);
document.getElementById('mask-opacity').addEventListener('input', renderEditCanvas);
document.getElementById('feather').addEventListener('input', schedulePreviewUpdate);

document.getElementById('btn-zoom-in').addEventListener('click', () => {
  zoom *= 1.2;
  renderEditCanvas();
});
document.getElementById('btn-zoom-out').addEventListener('click', () => {
  zoom /= 1.2;
  renderEditCanvas();
});
document.getElementById('btn-zoom-fit').addEventListener('click', fitToView);

document.getElementById('btn-undo').addEventListener('click', undo);
document.getElementById('btn-redo').addEventListener('click', redo);

document.getElementById('btn-upscale-carousel').addEventListener('click', upscaleCarouselAction);
document.getElementById('slide-count').addEventListener('input', updateTargetWidthLabel);

function beginPointer(e) {
  pointerPositions.set(e.pointerId, { x: e.clientX, y: e.clientY });

  if (pointerPositions.size === 2) {
    isDrawing = false;
    startPinchReference();
    try {
      editWrap.setPointerCapture(e.pointerId);
    } catch {
      /* ignore */
    }
    activePointerId = e.pointerId;
    return;
  }

  if (!sourceImage || !maskCanvas) {
    setStatus('Upload an image first, then paint on the canvas.', 'error');
    pointerPositions.delete(e.pointerId);
    return;
  }
  if (e.pointerType === 'mouse' && e.button !== 0 && e.button !== 1) return;

  if (spaceHeld || e.button === 1) {
    isPanning = true;
    activePointerId = e.pointerId;
    editWrap.classList.add('panning');
    try {
      editWrap.setPointerCapture(e.pointerId);
    } catch {
      /* ignore */
    }
    return;
  }

  try {
    editWrap.setPointerCapture(e.pointerId);
  } catch {
    /* ignore */
  }
  activePointerId = e.pointerId;

  const { x, y } = screenToImage(e.clientX, e.clientY);
  if (toolMode === 'wand') {
    pushUndo();
    floodFillPreserve(maskCanvas, sourceImage, x, y, 32);
    renderEditCanvas();
    schedulePreviewUpdate();
    setStatus('Wand fill applied.', 'ok');
    return;
  }

  pushUndo();
  isDrawing = true;
  lastImageX = x;
  lastImageY = y;
  paintAtImageCoords(x, y);
}

function movePointer(e) {
  if (pointerPositions.has(e.pointerId)) {
    pointerPositions.set(e.pointerId, { x: e.clientX, y: e.clientY });
  }

  if (pointerPositions.size === 2 && pinchRefDistance > 0) {
    const dist = pinchDistance();
    if (dist > 0) {
      const scale = dist / pinchRefDistance;
      const center = pinchCenterClient();
      const before = screenToImage(center.x, center.y);
      zoom = Math.max(0.05, Math.min(20, pinchRefZoom * scale));
      const after = screenToImage(center.x, center.y);
      panX += (after.x - before.x) * zoom;
      panY += (after.y - before.y) * zoom;
      renderEditCanvas();
    }
    return;
  }

  const { x, y } = screenToImage(e.clientX, e.clientY);
  hoverImageX = x;
  hoverImageY = y;

  if (activePointerId !== null && e.pointerId !== activePointerId) {
    renderEditCanvas();
    return;
  }

  if (isPanning) {
    const rect = editCanvas.getBoundingClientRect();
    const scaleX = rect.width > 0 ? editCanvas.width / rect.width : 1;
    const scaleY = rect.height > 0 ? editCanvas.height / rect.height : 1;
    panX += e.movementX * scaleX;
    panY += e.movementY * scaleY;
    renderEditCanvas();
    return;
  }

  if (!isDrawing) {
    renderEditCanvas();
    return;
  }
  paintAtImageCoords(x, y);
}

function endPointer(e) {
  pointerPositions.delete(e.pointerId);
  if (pointerPositions.size < 2) {
    pinchRefDistance = 0;
  }
  if (pointerPositions.size === 2) {
    startPinchReference();
  }

  if (activePointerId !== null && e.pointerId !== activePointerId) return;
  isDrawing = false;
  isPanning = false;
  activePointerId = null;
  editWrap.classList.remove('panning');
  try {
    editWrap.releasePointerCapture(e.pointerId);
  } catch {
    /* ignore */
  }
}

editWrap.addEventListener('pointerdown', beginPointer);
editWrap.addEventListener('pointermove', movePointer);
editWrap.addEventListener('pointerup', endPointer);
editWrap.addEventListener('pointercancel', endPointer);
editWrap.addEventListener('pointerleave', () => {
  hoverImageX = null;
  hoverImageY = null;
  if (!isDrawing && !isPanning) renderEditCanvas();
});

editWrap.addEventListener('wheel', (e) => {
  e.preventDefault();
  const rect = editCanvas.getBoundingClientRect();
  const scaleX = rect.width > 0 ? editCanvas.width / rect.width : 1;
  const scaleY = rect.height > 0 ? editCanvas.height / rect.height : 1;

  // Trackpad pinch is sent as wheel + ctrl (or meta on some browsers).
  if (e.ctrlKey || e.metaKey) {
    const factor = e.deltaY > 0 ? 0.9 : 1.1;
    zoomAtClient(e.clientX, e.clientY, factor);
    return;
  }

  // Two-finger scroll pans the view instead of zooming.
  panX -= e.deltaX * scaleX;
  panY -= e.deltaY * scaleY;
  renderEditCanvas();
}, { passive: false });

editWrap.addEventListener('contextmenu', (e) => e.preventDefault());

window.addEventListener('keydown', (e) => {
  if (e.target instanceof HTMLInputElement || e.target instanceof HTMLSelectElement) return;

  if (e.code === 'Space' && !spaceHeld) {
    spaceHeld = true;
    editWrap.classList.add('panning');
    e.preventDefault();
  }
  if (e.key === 'b' || e.key === 'B') setToolMode('brush');
  if (e.key === 'e' || e.key === 'E') setToolMode('eraser');
  if (e.key === 'w' || e.key === 'W') setToolMode('wand');
  if (e.key === '[') {
    const el = document.getElementById('brush-size');
    el.value = String(Math.max(4, Number(el.value) - 4));
    updateBrushLabel();
  }
  if (e.key === ']') {
    const el = document.getElementById('brush-size');
    el.value = String(Math.min(120, Number(el.value) + 4));
    updateBrushLabel();
  }
  if ((e.metaKey || e.ctrlKey) && e.key === 'z' && !e.shiftKey) {
    e.preventDefault();
    undo();
  }
  if ((e.metaKey || e.ctrlKey) && (e.key === 'Z' || (e.key === 'z' && e.shiftKey))) {
    e.preventDefault();
    redo();
  }
});

window.addEventListener('keyup', (e) => {
  if (e.code === 'Space') {
    spaceHeld = false;
    editWrap.classList.remove('panning');
  }
});

window.addEventListener('resize', () => {
  renderEditCanvas();
  renderPreviewCanvas();
});

updateBrushLabel();
setToolMode('brush');

if (typeof ResizeObserver !== 'undefined' && editWrap) {
  const resizeObserver = new ResizeObserver(() => {
    syncEditCanvasSize();
    renderPreviewCanvas();
    if (sourceImage) {
      fitToView();
    }
  });
  resizeObserver.observe(editWrap);
  const previewWrap = document.getElementById('preview-wrap');
  if (previewWrap) resizeObserver.observe(previewWrap);
}

requestAnimationFrame(() => {
  syncEditCanvasSize();
  renderEditCanvas();
  renderPreviewCanvas();
});

initCarouselConfig();
initKeyColorPicker();

// Drag-drop on edit area
editWrap.addEventListener('dragover', (e) => {
  e.preventDefault();
});
editWrap.addEventListener('drop', (e) => {
  e.preventDefault();
  const file = e.dataTransfer?.files?.[0];
  if (file && file.type.startsWith('image/')) loadImageFromFile(file);
});
