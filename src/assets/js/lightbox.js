/* src/js/lightbox.js - Clean Isolated Lightbox Engine */
document.addEventListener('DOMContentLoaded', () => {
  const overlay = document.getElementById('lightbox');
  const lightboxImg = document.getElementById('lightbox-img');
  
  if (!overlay || !lightboxImg) return;

  const closeBtn = document.getElementById('lightbox-close-btn');
  const prevBtn = document.getElementById('lightbox-prev-btn');
  const nextBtn = document.getElementById('lightbox-next-btn');
  const fsBtn = document.getElementById('fullscreen-btn');
  const copyBtn = document.getElementById('copy-link-btn');
  const toast = document.getElementById('lightbox-toast');

  let activeGalleryPhotos = [];
  let currentGalleryIndex = 0;

  // 1. Core Open View Trigger
  const openLightboxWithIndex = (index, photosArray) => {
    activeGalleryPhotos = photosArray;
    currentGalleryIndex = index;
    updateLightboxView();
    overlay.style.display = 'flex';
  };

  // 2. Sync State, Source Image & URL Hash
  const updateLightboxView = () => {
    const photo = activeGalleryPhotos[currentGalleryIndex];
    if (!photo) return;
    
    // Fallback pass: support both flatplan payload scheme (.fullUrl) and inline dynamic updates
    lightboxImg.src = photo.fullUrl || photo.thumbUrl.replace('/thumb/', '/full/');
    
    // Manage address bar history and deep-linking hash (#photo-slug)
    if (photo.filename && photo.context !== 'home') {
      const cleanName = photo.filename.split('.');
      const imgSlug = cleanName[0] || '';
      window.location.hash = imgSlug;
    }
  };

  // 3. Navigation Controls
  const lightboxNext = () => {
    if (activeGalleryPhotos.length === 0) return;
    currentGalleryIndex = (currentGalleryIndex + 1) % activeGalleryPhotos.length;
    updateLightboxView();
  };

  const lightboxPrev = () => {
    if (activeGalleryPhotos.length === 0) return;
    currentGalleryIndex = (currentGalleryIndex - 1 + activeGalleryPhotos.length) % activeGalleryPhotos.length;
    updateLightboxView();
  };

  const closeLightbox = () => {
    overlay.style.display = 'none';
    // Clear URL hash cleanly without forcing page layout shifts
    history.pushState("", document.title, window.location.pathname + window.location.search);
    if (document.fullscreenElement) {
      document.exitFullscreen().catch(() => {});
    }
  };

  // 4. Expose Safe Bridge Hooks to External Triggers (Main Mosaic & Series Page)
  window.ExposureLightbox = {
    open: openLightboxWithIndex,
    next: lightboxNext,
    prev: lightboxPrev,
    close: closeLightbox
  };

  // 5. Clicks Bindings
  if (closeBtn) closeBtn.addEventListener('click', closeLightbox);
  if (prevBtn)  prevBtn.addEventListener('click', lightboxPrev);
  if (nextBtn)  nextBtn.addEventListener('click', lightboxNext);

  // Keyboard controls (Esc, Arrows, F)
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

  // Fullscreen Icon Button Link
  if (fsBtn) {
    fsBtn.addEventListener('click', () => {
      if (!document.fullscreenElement) {
        overlay.requestFullscreen().catch(() => {});
      } else {
        document.exitFullscreen();
      }
    });
  }

  // Direct Share Link Copy Action
  if (copyBtn) {
    copyBtn.addEventListener('click', () => {
      const shareUrl = window.location.href;
      navigator.clipboard.writeText(shareUrl).then(() => {
        if (!toast) return;
        toast.classList.add('visible');
        setTimeout(() => {
          toast.classList.remove('visible');
        }, 2000);
      }).catch(err => console.error('Share link copy failed:', err));
    });
  }
});
