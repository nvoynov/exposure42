/* src/js/series_lightbox.js - Dynamic Series Flatplan Layout Lightbox Binder */
document.addEventListener('DOMContentLoaded', () => {
  // Locate all photograph image nodes embedded inside the flatplan media grids or heroes
  const seriesImages = Array.from(document.querySelectorAll('.flatplan_media_grid img, .flatplan_editorial_hero img'));
  
  if (seriesImages.length === 0) return;

  // Compile a clean unified database pool matching the lightbox structure expectations
  const seriesPhotosPool = seriesImages.map(img => {
    const thumbUrl = img.src;
    // Elegant path math: replace the /thumbs/ subfolder with /full/ directory token dynamically
    const fullUrl = thumbUrl.replace('/thumb/', '/full/');
    
    return {
      "thumbUrl": thumbUrl,
      "fullUrl": fullUrl,
      "filename": thumbUrl.split('/').pop(), // Extract filename for hash deep-linking tracks
      "title": img.alt || ""
    };
  });

  // Bind click actions to every discovered image tile node
  seriesImages.forEach((img, currentIndex) => {
    img.style.cursor = 'pointer'; // Visual indicator
    
    img.addEventListener('click', () => {
      if (window.ExposureLightbox) {
        // Fire up the modal window passing the calculated index pointer and unified pool
        window.ExposureLightbox.open(currentIndex, seriesPhotosPool);
      }
    });
  });
});

/* ==========================================================================
   PRODUCTION DEEP LINKING ENGINE - ROBUST DOM MUTATION PROBER
   ========================================================================== */

/**
 * Parses the active URL hash channel and safely triggers the underlying 
 * lightbox view overlay context once target nodes are fully mounted.
 */
function resolveActivePhotoHash() {
  const hash = window.location.hash;
  if (!hash) return;

  // Clean the hash fragment string layout to extract the raw filename slug
  const cleanId = decodeURIComponent(hash.substring(1));
  if (!cleanId) return;

  console.log(`==> [DeepLink] Investigating DOM for target asset reference: #${cleanId}`);

  // Query specific photographic image element containing the clean negative string name
  const targetImg = document.querySelector(`img[src*="${cleanId}"]`);

  if (targetImg) {
    console.log(`--> [DeepLink] Found node target. Instantiating explicit activation...`);
    
    // We explicitly dispatch a custom dynamic click pointer event directly to the 
    // image node, stopping native browser link redirection bubbles.
    const clickEvent = new MouseEvent('click', {
      bubbles: true,
      cancelable: true,
      view: window
    });
    
    targetImg.dispatchEvent(clickEvent);
  } else {
    // If images are not ready yet, we spawn a temporary structural observer loop
    waitForImageToLoadInDOM(cleanId);
  }
}

/**
 * Mutation tracking thread waiting for slow asynchronous DOM scripts to mount photo items
 */
function waitForImageToLoadInDOM(targetId) {
  if (window.__sw_hash_observer) window.__sw_hash_observer.disconnect();

  const observer = new MutationObserver((mutations, obs) => {
    const targetImg = document.querySelector(`img[src*="${targetId}"]`);
    if (targetImg) {
      console.log(`==> [DeepLink Observer] Target image deferred resolution mounted cleanly.`);
      targetImg.click();
      obs.disconnect(); // Terminate observer loop instantly to save resource runtime memory
    }
  });

  window.__sw_hash_observer = observer;
  observer.observe(document.body, { childList: true, subtree: true });

  // Safety threshold timeout: disconnect tracking if no items found within 3 seconds
  setTimeout(() => observer.disconnect(), 3000);
}

// 1. Core Initialization Gateway: Enforce safe lifecycle evaluation checkpoints
if (document.readyState === 'complete') {
  resolveActivePhotoHash();
} else {
  window.addEventListener('DOMContentLoaded', resolveActivePhotoHash);
  window.addEventListener('load', resolveActivePhotoHash);
}

// 2. Navigation Gateway: Listen for inside hash navigation state switches
window.addEventListener('hashchange', resolveActivePhotoHash);

