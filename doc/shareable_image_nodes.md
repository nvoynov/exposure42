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
