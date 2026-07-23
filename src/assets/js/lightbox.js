/* ==========================================================================
   RAWWW CORE LIGHTBOX & DEEP LINKING ENGINE (DYNAMIC LIVE DOM PACK)
   ========================================================================== */

document.addEventListener('DOMContentLoaded', () => {
  // --- LAYER 1: LIGHTBOX MODAL CORE ENGINE ---
  const overlay = document.getElementById('lightbox');
  const lightboxImg = document.getElementById('lightbox-img');
  
  if (!overlay || !lightboxImg) return;

  const closeBtn = document.getElementById('lightbox-close-btn');
  const prevBtn = document.getElementById('lightbox-prev-btn');
  const nextBtn = document.getElementById('lightbox-next-btn');
  const fsBtn = document.getElementById('fullscreen-btn');
  const copyBtn = document.getElementById('copy-link-btn');
  const toast = document.getElementById('lightbox-toast');

  let photosPool = [];
  let currentGalleryIndex = 0;

  // 1. Open Trigger
  const openLightboxWithIndex = (index) => {
    if (photosPool.length === 0) return;
    currentGalleryIndex = index;
    updateLightboxView();
    overlay.style.display = 'flex';
  };

  // 2. Sync State & URL Hash
  const updateLightboxView = () => {
    const photo = photosPool[currentGalleryIndex];
    if (!photo) return;
    
    lightboxImg.src = photo.fullUrl || photo.thumbUrl.replace('/thumb/', '/full/');
    
    if (photo.filename) {
      const cleanName = photo.filename.split('.');
      const imgSlug = cleanName[0] || '';
      window.location.hash = imgSlug;
    }
  };

  // 3. Navigation Controls
  const lightboxNext = () => {
    if (photosPool.length === 0) return;
    currentGalleryIndex = (currentGalleryIndex + 1) % photosPool.length;
    updateLightboxView();
  };

  const lightboxPrev = () => {
    if (photosPool.length === 0) return;
    currentGalleryIndex = (currentGalleryIndex - 1 + photosPool.length) % photosPool.length;
    updateLightboxView();
  };

  const closeLightbox = () => {
    overlay.style.display = 'none';
    history.pushState("", document.title, window.location.pathname + window.location.search);
    if (document.fullscreenElement) {
      document.exitFullscreen().catch(() => {});
    }
  };

  // Bind Clicks & Keys
  if (closeBtn) closeBtn.addEventListener('click', closeLightbox);
  if (prevBtn)  prevBtn.addEventListener('click', lightboxPrev);
  if (nextBtn)  nextBtn.addEventListener('click', lightboxNext);

  document.addEventListener('keydown', (e) => {
    if (overlay.style.display !== 'flex') return;
    if (e.key === 'Escape') closeLightbox();
    if (e.key === 'ArrowRight') lightboxNext();
    if (e.key === 'ArrowLeft') lightboxPrev();
    if (e.key === 'f' || e.key === 'F') {
      e.preventDefault();
      if (!document.fullscreenElement) overlay.requestFullscreen().catch(() => {});
      else document.exitFullscreen();
    }
  });

  if (fsBtn) {
    fsBtn.addEventListener('click', () => {
      if (!document.fullscreenElement) overlay.requestFullscreen().catch(() => {});
      else document.exitFullscreen();
    });
  }

  if (copyBtn) {
    copyBtn.addEventListener('click', () => {
      navigator.clipboard.writeText(window.location.href).then(() => {
        if (!toast) return;
        toast.classList.add('visible');
        setTimeout(() => toast.classList.remove('visible'), 2000);
      }).catch(err => console.error('Share link copy failed:', err));
    });
  }


  // --- LAYER 2: LIVE DOM POOL REFRESHER ---

  const initGalleryPool = () => {
    // Universal selector: queries standard tags anywhere in the body context
    const pageImages = Array.from(document.querySelectorAll('.flatplan_media_grid img, .flatplan_editorial_hero img, #mosaic-grid img'));
    
    if (pageImages.length === 0) return false;

    // Compile database pool
    photosPool = pageImages.map(img => {
      const thumbUrl = img.src;
      return {
        "thumbUrl": thumbUrl,
        "fullUrl": thumbUrl.replace('/thumb/', '/full/'),
        "filename": thumbUrl.split('/').pop(),
        "title": img.alt || ""
      };
    });

    // Re-bind click pointers clean execution stream
    pageImages.forEach((img, currentIndex) => {
      img.style.cursor = 'pointer';
      // Remove old listener if exists to prevent double triggers
      img.removeEventListener('click', img._lightboxClick);
      
      img._lightboxClick = () => openLightboxWithIndex(currentIndex);
      img.addEventListener('click', img._lightboxClick);
    });

    return true;
  };


  // --- LAYER 3: ROBUST MUTATION TRACKER & ROUTER ---
  
  function resolveActivePhotoHash() {
    const hash = window.location.hash;
    if (!hash) return;

    const cleanId = decodeURIComponent(hash.substring(1));
    if (!cleanId) return;

    const targetIndex = photosPool.findIndex(p => p.filename.includes(cleanId));

    if (targetIndex !== -1) {
      openLightboxWithIndex(targetIndex);
    } else {
      // Soft cleanup if deep-linked asset is absent
      history.replaceState("", document.title, window.location.pathname + window.location.search);
    }
  }

  // First pass: scan what is currently available in native HTML layout channel
  const hasImagesOnLoad = initGalleryPool();
  if (hasImagesOnLoad) {
    resolveActivePhotoHash();
  }

  // Modern Mutation Observer thread to handle asynchronous mosaic streams injections
  const observer = new MutationObserver(() => {
    const freshBuildSuccess = initGalleryPool();
    if (freshBuildSuccess) {
      resolveActivePhotoHash(); // Trigger evaluation track on successful dynamic mount
    }
  });

  observer.observe(document.body, { childList: true, subtree: true });

  // Listen for manual address bar changes
  window.addEventListener('hashchange', resolveActivePhotoHash);
});
