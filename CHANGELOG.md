## [Unreleased]

TODO

__Rawww__

- [ ] add `Cpnfig#production?` based on ENV
- [ ] fix cannonical url for nested html pages

__nvoynov.art__

- [ ] connnect analytics codes
  - [ ] nvoynov.dev
  - [ ] nvoynov.art
- [ ] review main series with Gemini and make final PUBLIC.md
- [ ] buy domain
- [ ] deploy on domain

__nvoynov.dev__

- [ ] apply Rawww changes!

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
