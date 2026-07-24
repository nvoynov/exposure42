/* ==========================================================================
   RAWWW CORE LIGHTBOX & DEEP LINKING ENGINE (DYNAMIC LIVE DOM PACK)
   ========================================================================== */

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

  // ХРАНИЛИЩА РАЗДЕЛЕНЫ:
  let domParsedPool = [];       // Сюда MutationObserver собирает картинки из HTML
  let currentActivePool = [];   // А этот пул ЛИСТАЕТ лайтбокс (может быть альбомом)
  let currentGalleryIndex = 0;

  // 1. Open Trigger (Теперь железобетонный)
  const openLightboxWithIndex = (index, customPhotosArray = null) => {
    // Если мозаика передала скрытый альбом — берем его, если нет — берем слепок DOM страницы
    currentActivePool = customPhotosArray ? customPhotosArray : [...domParsedPool];
    
    if (currentActivePool.length === 0) return;
    currentGalleryIndex = index;
    updateLightboxView();
    overlay.style.display = 'flex';
  };

  // 2. Sync State & URL Hash
  const updateLightboxView = () => {
    const photo = currentActivePool[currentGalleryIndex];
    if (!photo) return;
    
    lightboxImg.src = photo.fullUrl || photo.thumbUrl.replace('/thumb/', '/full/');
    
    if (photo.filename) {
      const cleanName = photo.filename.split('.');
      const imgSlug = cleanName[0] || '';
      window.location.hash = imgSlug;
    }
  };

  // 3. Navigation Controls (работают с изолированным активным пулом)
  const lightboxNext = () => {
    if (currentActivePool.length === 0) return;
    currentGalleryIndex = (currentGalleryIndex + 1) % currentActivePool.length;
    updateLightboxView();
  };

  const lightboxPrev = () => {
    if (currentActivePool.length === 0) return;
    currentGalleryIndex = (currentGalleryIndex - 1 + currentActivePool.length) % currentActivePool.length;
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
    const pageImages = Array.from(document.querySelectorAll('.flatplan_media_grid img, .flatplan_editorial_hero img, #mosaic-grid img'));
    if (pageImages.length === 0) return false;

    // Скрипт обновляет ТОЛЬКО слепок страницы, не трогая то, что сейчас открыто в лайтбоксе
    domParsedPool = pageImages.map(img => {
      const thumbUrl = img.src;
      return {
        "thumbUrl": thumbUrl,
        "fullUrl": thumbUrl.replace('/thumb/', '/full/'),
        "filename": thumbUrl.split('/').pop(),
        "title": img.alt || ""
      };
    });

    // Привязываем клики
    pageImages.forEach((img, currentIndex) => {
      img.style.cursor = 'pointer';
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

    // Ищем картинку в актуальном пуле, который СЕЙЧАС открыт в лайтбоксе, 
    // либо в слепке страницы, если лайтбокс закрыт
    const activePoolToSearch = overlay.style.display === 'flex' ? currentActivePool : domParsedPool;
    const targetIndex = activePoolToSearch.findIndex(p => p.filename.includes(cleanId));

    if (targetIndex !== -1) {
      // Если мы уже смотрим этот альбом, просто синхронизируем индекс, не перезаписывая пул
      if (overlay.style.display === 'flex') {
        currentGalleryIndex = targetIndex;
        updateLightboxView();
      } else {
        openLightboxWithIndex(targetIndex);
      }
    } else {
      // Если картинки нет в текущем активном пуле — мягко чистим хэш
      if (overlay.style.display !== 'flex') {
        history.replaceState("", document.title, window.location.pathname + window.location.search);
      }
    }
  }

  // Экспортируем мост для внешних вызовов (mosaic.js)
  window.ExposureLightbox = {
    open: openLightboxWithIndex
  };

  // Стартовый запуск
  const hasImagesOnLoad = initGalleryPool();
  if (hasImagesOnLoad) {
    resolveActivePhotoHash();
  }

  // ЖЕЛЕЗОБЕТОННЫЙ ОБСЕРВЕР: Засыпает, как только открывается лайтбокс
  const observer = new MutationObserver(() => {
    // Если пользователь открыл лайтбокс — ИГНОРИРУЕМ любые изменения DOM
    if (overlay.style.display === 'flex') return;

    const freshBuildSuccess = initGalleryPool();
    if (freshBuildSuccess) {
      resolveActivePhotoHash(); 
    }
  });

  observer.observe(document.body, { childList: true, subtree: true });

  window.addEventListener('hashchange', resolveActivePhotoHash);
});
