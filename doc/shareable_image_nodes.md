---
title: "Architectural Blueprint: Shareable Image Nodes & SEO Integration"
author: RAWWW Architecture Group
date: 2026-07-25
---

# Specification: Shareable Image Nodes Architecture

This document describes the architectural layout for implementing dedicated, light-weight HTML static endpoints for individual photographs within the **RAWWW** engine. 

This approach resolves the core limitations of static hosting environments (e.g., GitHub Pages) regarding Rich Preview Generation (`OpenGraph/og:image`) for deep-linked media assets, while expanding the site's footprint in search engine indexes (**Google Images**).

---

## The Structural Matrix

When a user or a social media crawler accesses a deep-linked asset, the system behaves conditionally based on the consumer:

```
[User or Crawler Link Click]
│
▼
/series/album/P1001468.html
│
├─► (Social Crawler) ──► Reads static  -> Returns unique og:image & print details
│
└─► (Real Browser)   ──► Triggers inline JS ──► Instant redirect to /series/album.html#P1001468
````
---

## 1. Directory Topology

The Ruby builder pipeline will extend the existing плоский (flat) structure by generating nested document nodes inside matching album subdirectory namespaces:

```text
www/
├── series/
│   ├── diamond-dust.html          <-- Main exhibition container (The view layer)
│   └── diamond-dust/              <-- Isolated shared components namespace directory
│       ├── P1001468.html          <-- Lightweight asset metadata node (The donor)
│       └── P1011861.html
└── sitemap.xml
```

---

## 2. Dynamic Blueprint Layout Template

Each independent image node (`P1001468.html`) acts as a dedicated metadata container. The Ruby pipeline processes these via a **Presenter Pattern** to inject structured properties (dimensions, limited editions, print availability, custom titles) directly into the static markup.

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>title | Fine-Art Print Specifications</title>
    
    <!-- OpenGraph Matrix for Social Platforms Core Injections -->
    <meta property="og:type" content="article">
    <meta property="og:title" content="title — Photographic Print Edition">
    <meta property="og:description" content="description (dimensions, Edition: \(edition_info\))">
    <meta property="og:image" content="\(site_url\)/assets/series/\(album_slug\)/full/filename">
    <meta property="og:url" content="\(site_url\)/series/\(album_slug\)/filename.html">
    
    <!-- Search Engine Index Optimization Hooks -->
    <meta name="description" content="description. Fine-art photographic prints available: \(print_status\).">
    <link rel="canonical" href="\(site_url\)/series/\(album_slug\)/filename.html">

    <!-- The Gateway Redirect Trigger Execution Frame -->
    <script>
        // Immediately route real human visitors back to the rich interactive Lightbox stage
        window.location.replace("../\(album_slug\).html#\(slug_name\)");
    </script>
</head>
<body>
    <!-- Fallback layout semantics rendered only if JavaScript is completely disabled -->
    <main>
        <article itemscope itemtype="https://schema.org">
            <h1 itemprop="name">title</h1>
            <p itemprop="abstract">description</p>
            <img src="../../assets/series/\(album_slug\)/full/filename" itemprop="image" alt="title">
            
            <!-- E-Commerce Print Architecture Context (Future Presenter Data Layer Mounting) -->
            <section class="print-meta-rack">
                <h2>Fine-Art Print Details</h2>
                <ul>
                    <li><strong>Original Resolution:</strong> dimensions</li>
                    <li><strong>Availability Status:</strong> \(print_status\)</li>
                    <li><strong>Acquisition Inquiry:</strong> Please reference item token code: <code>filename</code></li>
                </ul>
            </section>
        </article>
    </main>
</body>
</html>
```

---

## 3. The Ruby Pipeline Integration Plan

To keep your raw text files (`.md`) pristine and decoupled from distribution maintenance loops, the compilation cycle should occur entirely in your Rake orchestration layer via a dedicated Presenter pipeline object:

1. **The Print Tracker Module** queries your data store and serves complete print inventory models.
2. **The RAWWW::ImageNodePresenter** intercepts the standard array stream and maps metadata variables.
3. The core compiler pipes these fields into the raw layout markup without triggering heavyweight Pandoc compilation cycles for performance reasons (simple, high-speed string replacement).

---

## 4. Modern Sitemap Architecture (`sitemap.xml`)

Following the modern SEO guidelines, search engines no longer require legacy extended schema tags (`<image:image>`, `<image:caption>`) inside the XML structure itself. Crawlers extract all semantic data directly from context containers on accessible HTML endpoints.

Therefore, your Ruby Sitemap Generator should dynamically index **both** your gallery view containers and the new individual asset nodes directly as plain URLs:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://sitemaps.org">
  
  <!-- 1. The Main Series Album Layer -->
  <url>
    <loc>https://github.io</loc>
    <lastmod>2026-07-25</lastmod>
    <changefreq>weekly</changefreq>
    <priority>0.8</priority>
  </url>

  <!-- 2. Individual Shared Asset Endpoints (Indexed for Google Images optimization) -->
  <url>
    <loc>https://github.io</loc>
    <lastmod>2026-07-25</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.5</priority>
  </url>
  
  <url>
    <loc>https://github.io</loc>
    <lastmod>2026-07-25</lastmod>
    <changefreq>monthly</changefreq>
    <priority>0.5</priority>
  </url>

</urlset>
```

---

## Architectural Advantages

* **High-Utility Crawling Strategy**: Clean separation between heavy UI rendering logic and lightweight metadata endpoints.
* **Flawless Client Routing**: `window.location.replace()` replaces the browser history state, preventing broken navigation tracks when a user hits the "Back" button.
* **SEO Data Integrity**: Google indexes individual files based on native HTML context layout properties, avoiding unmaintained legacy `<image:...>` XML structures.

