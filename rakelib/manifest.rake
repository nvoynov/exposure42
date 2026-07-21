# rakelib/manifest.rake

require 'fileutils'
require 'pathname'
require_relative 'helper'

namespace :manifest do

  SERIES = GALLERY.series.reject(&:hidden?)
  SERIES_DIR = File.join(SRC_DIR, 'series')
  SERIES_INDEX = SERIES_DIR + '.md'
  
  desc "Build series index"
  file "#{SERIES_DIR}.md" do |t|
    raw = Exposure::BuildSeriesIndexPage.call(GALLERY)
    File.write(t.name, raw)
  end

  # Create series page builder
  BUILD_SERIES_PAGE = Exposure::BuildSeriesPage.new

  mk_series_page = proc do |e, hash|
    key = File.join(SERIES_DIR, e.slug + '.md')
    hash[key] = e
  end

  SERIES_PAGES = SERIES.each_with_object({}, &mk_series_page)
    #.tap{ pp it }
  
  desc "Build series pages"
  rule(%r{^#{SERIES_DIR}/.*md$}) do |t|
    FileUtils.mkdir_p File.dirname(t.name)
    File.write(t.name, BUILD_SERIES_PAGE.call(SERIES_PAGES[t.name]))
  end

  # images
  ASSETS = File.join(SRC_DIR, 'assets')
  IMAGE_ASSETS  = File.join(ASSETS, 'images')
  directory IMAGE_ASSETS

  
  SERIES_ASSETS = GALLERY.series.flat_map do |series|
    source_path = File.join(series.directory_path)
    target_path = File.join(IMAGE_ASSETS, series.slug)

    series.media_assets.map(&:filename)
      .each_with_object({}) do |filename, hash|
        key = File.join(target_path, filename.sub(/\..*$/, '.webp'))
        hash[key] = File.join(source_path, filename)
      end#
  end.reduce({}, :merge)

  SERIES_FULL = SERIES_ASSETS
    .transform_keys{
      filepath = Pathname.new(it)
      path = File.dirname(filepath)
      file = File.basename(filepath)
      File.join(path, 'full', file)
    }#.tap { pp it }
  
  SERIES_THUMB = [
    File::SEPARATOR + 'full' + File::SEPARATOR,
    File::SEPARATOR + 'thumb' + File::SEPARATOR
  ].then{|pat, sub|
    SERIES_FULL.transform_keys{ it.sub(pat, sub) }
  }#.tap{ pp it }

  MAGICK = Exposure::Magick.new

  desc "convert full images"
  rule(%r{/full/.*webp$}) do |t|
    source = SERIES_FULL[t.name]
    FileUtils.mkdir_p File.dirname(Pathname(t.name))
    MAGICK.convert_to_full(source, t.name)
    puts "  » convert full image: -> #{t.name}"
  end  

  desc "convert thumbnail"
  rule(%r{/thumb/.*webp$}) do |t|
    source = SERIES_THUMB[t.name]
    FileUtils.mkdir_p File.dirname(Pathname(t.name))
    MAGICK.convert_to_thumb(source, t.name)
    puts "  » convert thumbnail: -> #{t.name}"
  end  

  MOSAIC_MANIFEST = File.join(ASSETS, 'manifest.json')
  desc "Build mosaic manifest"
  file MOSAIC_MANIFEST do |t|
    raw = Exposure::BuildMosaicManifest.call(GALLERY)
    File.write(t.name, raw)
    puts "  » mosaic mainifest: -> #{t.name}"
  end

  desc "Build gallery manifest"
  task :sync => (
    [SERIES_INDEX, MOSAIC_MANIFEST] +
    SERIES_PAGES.keys +
    SERIES_FULL.keys +
    SERIES_THUMB.keys
  )

  desc "Clean staged manifest source"
  task :clean do
    FileUtils.rm_rf SERIES_DIR
    File.delete(SERIES_INDEX) if File.exist?(SERIES_INDEX)
  end
end
