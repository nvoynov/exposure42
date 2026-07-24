/* src/js/mosaic.js - "Todd Hido" inspired Engine with Hidden Series Lightbox Exploration */
document.addEventListener('DOMContentLoaded', () => {
  const gridContainer = document.getElementById('mosaic-grid');
  
  // LIVE AUTO-DETECTION:
  //   calculates GitHub Pages produtction root, otherwise returns "" 
  const getDynamicBaseUrl = () => {
    const isGitHubPages = window.location.hostname.includes('github.io');
    
    if (isGitHubPages) {
      const repoName = window.location.pathname.split('/').filter(Boolean)[0];
      return repoName ? `/${repoName}` : "";
    }
    return "";
  };

  const baseUrl = getDynamicBaseUrl();
  
  const sizeClasses = [
    'size-normal', 'size-normal', 'size-normal', 
    'size-tall', 'size-tall', 
    'size-wide', 
    'size-large', 
    'spacer', 'spacer'
  ];

  // 1. Fetch the runtime gallery manifest compiled by the Rake pipeline
  fetch(`${baseUrl}/assets/manifest.json`)
    .then(response => {
      if (!response.ok) throw new Error("Failed to load gallery manifest target");
      return response.json();
    })
    .then(payload => {
      const rawData = payload.series || [];
      let allPhotosPool = [];

      // We preserve the full rawData structure to extract entire albums on click passes
      rawData.forEach(album => {
        album.photos.forEach(photo => {
          allPhotosPool.push({
            "slug": album.album_slug,
            "filename": photo.filename,
            "thumbUrl": `${baseUrl}/assets/series/${album.album_slug}/thumb/${photo.filename}`,
            "fullUrl": `${baseUrl}/assets/series/${album.album_slug}/full/${photo.filename}`,
            "title": photo.title,
            // Keep a clean reference to all fellow sibling photos inside the same series container
            "albumPhotosRef": album.photos.map(p => ({
              "slug": album.album_slug,
              "filename": p.filename,
              "thumbUrl": `${baseUrl}/assets/series/${album.album_slug}/thumb/${p.filename}`,
              "fullUrl": `${baseUrl}/assets/series/${album.album_slug}/full/${p.filename}`,
              "title": p.title
            }))
          });
        });
      });

      buildDynamicCanvas(allPhotosPool);
    })
    .catch(err => console.error("==> [Mosaic Engine] Critical failure:", err));

  // 2. Random shuffle engine
  function shuffleArray(array) {
    for (let i = array.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [array[i], array[j]] = [array[j], array[i]];
    }
    return array;
  }

  // 3. Dynamic height-bound wall layout generator
  function buildDynamicCanvas(allPhotosPool) {
    if (!gridContainer) return;

    const shuffledPool = shuffleArray([...allPhotosPool]);
    gridContainer.innerHTML = '';

    const maxViewportHeight = gridContainer.parentElement.clientHeight;
    const isDesktop = window.innerWidth > 767;
    const maxColumns = isDesktop ? 4 : 2;
    
    let poolIndex = 0;
    let currentColumnTrack = 0;
    let displayedImagesCount = 0;
    
    while (poolIndex < shuffledPool.length) {
      let randomSize = sizeClasses[Math.floor(Math.random() * sizeClasses.length)];
      
      if (isDesktop && currentColumnTrack === (maxColumns - 1)) {
        const restrictiveFilters = ['size-normal', 'size-tall', 'spacer'];
        randomSize = restrictiveFilters[Math.floor(Math.random() * restrictiveFilters.length)];
      }

      const columnSpan = (randomSize === 'size-wide' || randomSize === 'size-large') ? 2 : 1;
      const item = document.createElement('div');
      
      if (randomSize === 'spacer') {
        if (isDesktop) {
          item.className = 'mosaic-item size-normal';
          item.style.visibility = 'hidden'; 
          item.style.pointerEvents = 'none';
          gridContainer.appendChild(item);
        }
      } else {
        const photo = shuffledPool[poolIndex];
        item.className = `mosaic-item ${randomSize}`;
        item.innerHTML = `<img src="${photo.thumbUrl}" alt="" loading="lazy">`;
        gridContainer.appendChild(item);

        if (isDesktop && maxViewportHeight > 0 && gridContainer.scrollHeight > maxViewportHeight && displayedImagesCount > 4) {
          gridContainer.removeChild(item);
          break;
        }

        if (!isDesktop && displayedImagesCount >= 6) {
          gridContainer.removeChild(item);
          break;
        }

        // --- THE DISCOVERY MAGIC MECHANISM ---
        // Find the precise structural array sequence of the parent target album track
        const targetSeriesArray = photo.albumPhotosRef;
        const localPhotoIndex = targetSeriesArray.findIndex(p => p.filename === photo.filename);

        item.addEventListener('click', () => {
          if (window.ExposureLightbox) {
            // Trigger the lightbox, loading the ENTIRE native parent series data block!
            window.ExposureLightbox.open(localPhotoIndex >= 0 ? localPhotoIndex : 0, targetSeriesArray);
          }
        });

        poolIndex++;
        displayedImagesCount++;
      }
      
      currentColumnTrack = (currentColumnTrack + columnSpan) % maxColumns;
      
      if (isDesktop && maxViewportHeight > 0 && gridContainer.scrollHeight > maxViewportHeight) {
        break;
      }
    }

    const injectedCards = Array.from(gridContainer.querySelectorAll('.mosaic-item'))
                               .filter(card => card.style.visibility !== 'hidden');
                               
    injectedCards.forEach((card, index) => {
      setTimeout(() => {
        card.classList.add('revealed');
      }, index * 100);
    });
  }
});
