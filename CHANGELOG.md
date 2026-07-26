## [Unreleased]

TODO

__Rawww__

- [ ] add `Cpnfig#production?` based on ENV
- [ ] fix cannonical url for nested html pages

__nvoynov.art__

- [ ] check sw.js and cache_mainifes.json! it might be lost!
  ```
  ...
  "/assets/series/svalovichi/thumb/DP2Q3359.webp": 1785000267,
  "/assets/series/svalovichi-two-journeys/full/DP0Q0549.webp": 1785000244,
  ...
  "/assets/series/the-fluid-axes/thumb/P1011861.webp": 1785000261,
  "/assets/series/the-fluid-axes/thumb/P1012097.webp": 1785000262,
  "/assets/series/vaseline/full/P1001495.webp": 1785000223,
  "/assets/series/vaseline/full/P1001501.webp": 1785000223,
  ```
- [ ] make Rawww js.rake for js minification
- [ ] port Rawww style.rake and js.rake
- [ ] move image_pages.rake logick into manifest.rake
      maybe rename image.rake to mainifest_images.rake
      and left images.rake for standard image assetes that
      moves src/assets/images into www/assets/images
- [ ] optimize rake tasks the next way
  - [ ] prune www/series/**/*.web NOT remove; *.webp do not affect
        site_path and that significantly reduces build/deploy pipelines
  - [ ] prune src/series/**/*.html NOT remove, that reduces
        buiid/deploy pipeline and preserves series and images
        pages mtime for sitemap.xml
  - [ ] assets.rake deals with /src/assets/*.* only?


- [ ] mabye .gitinore should ignore src/series, or all improted content
- [ ] port `rake.css` logic from Rawww
- [ ] connnect analytics codes
  - [ ] nvoynov.dev
  - [ ] nvoynov.art
- [ ] review main series with Gemini and make final PUBLIC.md
- [ ] buy domain
- [ ] deploy on domain

__nvoynov.dev__

- [ ] apply Rawww changes!

## 2026-07-25

- optimized `mosaic.js` for usign full images for big tiles
- optimized `manifest.json` by cleaning extra data like "title"
- changed `build/mosaic_manifest.rb` for providing only necessary data
- added unique image pages "Fine-Art print sepcification" with og:image
  simplified lightbox.js; no more `#image`-hashed links

## 2026-07-24

__NOTE:__ `rake deploy` generate site the way it brokes local site serving. Do

    rake clean
    rake [build]
    rake serve

- improved `Rawww` by providing Config `#production?` and `#site_root`
- improved `default.html` template by providing include-before and after
- fixed `index.md` (static thing) by referencing scripts relative paths
- fixed `Build::SeriesPage` by providing `lightbox.js` absolute path
- `rake push` renamed to `rake deploy`
- added `image:prune` task

## 2026-07-23

- ported Rawww v0.2.0 changes
- designed new images.rake flow series images
- merged ligthbox.js and series_lightbox.js into lightbox.js
- desigend new main og_image and personal series og_image
- provided right image links in SeriesSerializer

## 2026-07-21

- ported exposure code
- it works!
