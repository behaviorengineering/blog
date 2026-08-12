/**
 * Motif editor runtime panorama config (defaults from /static/carousel/slide-constants.js).
 */

export {
  CAROUSEL_SLIDE_WIDTH_PX,
  PANORAMA_SLIDE_WIDTH_PX,
  PANORAMA_GAP_PX,
  motifStripSeamlessWidthPx,
  panoramaWidthWithGapsPx,
  stripSlideGapPx,
} from '/static/carousel/slide-constants.js';

import {
  PANORAMA_SLIDE_WIDTH_PX as DEFAULT_PANORAMA_SLIDE_WIDTH_PX,
  PANORAMA_GAP_PX as DEFAULT_PANORAMA_GAP_PX,
} from '/static/carousel/slide-constants.js';

/** @type {number} */
export let panoramaSlideWidthPx = DEFAULT_PANORAMA_SLIDE_WIDTH_PX;
/** @type {number} */
export let panoramaGapPx = DEFAULT_PANORAMA_GAP_PX;

/**
 * @param {{ panoramaSlideWidthPx?: number, panoramaGapPx?: number }} config
 */
export function applyPanoramaConfig(config) {
  if (Number.isFinite(config.panoramaSlideWidthPx) && config.panoramaSlideWidthPx > 0) {
    panoramaSlideWidthPx = config.panoramaSlideWidthPx;
  }
  if (Number.isFinite(config.panoramaGapPx) && config.panoramaGapPx > 0) {
    panoramaGapPx = config.panoramaGapPx;
  }
}
