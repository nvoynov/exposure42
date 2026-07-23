# rakelib/manifest.rake

require 'fileutils'
require 'pathname'
require_relative 'helper'

namespace :images do

  # series for producing og_image
  SERIES = GALLERY.series.reject(&:hidden?)
  
  GALLERY_ASSETS_DIR = File.join(WWW_DIR, EXPOSURE_CONFIG.target_series_dir)
  directory GALLERY_ASSETS_DIR
  
  # hashmaps of target webp, source tif    
  SERIES_FULL  = GALLERY.full_webp_targets
    .transform_keys{ File.join(WWW_DIR, it) }

  SERIES_THUMB = GALLERY.thumb_webp_targets
    .transform_keys{ File.join(WWW_DIR, it) }

  # Image transformer
  MAGICK = Exposure::Magick.new

  desc "convert full images"
  rule(%r{/full/.*webp$} => [ ->(t_name) { 
    source = SERIES_FULL[t_name] 
    if source.nil?
      puts "[DEBUG ERROR] rule 'full' cannot find source for target: #{t_name.inspect}"
      "" 
    else
      source
    end
  } ]) do |t|
    FileUtils.mkdir_p File.dirname(t.name)
    MAGICK.convert_to_full(t.source, t.name)
    puts "  » convert full image: -> #{t.name}"
  end

  desc "convert thumbnail"
  rule(%r{/thumb/.*webp$} => [ ->(t_name) { 
    source = SERIES_THUMB[t_name]
    if source.nil?
      puts "[DEBUG ERROR] rule 'thumb' cannot find source for target: #{t_name.inspect}"
      ""
    else
      source
    end
  } ]) do |t|
    FileUtils.mkdir_p File.dirname(t.name)
    MAGICK.convert_to_thumb(t.source, t.name)
    puts "  » convert thumbnail: -> #{t.name}"
  end

  ASSETS = File.join(WWW_DIR, 'assets')
  MOSAIC_MANIFEST = File.join(ASSETS, 'manifest.json')
  directory ASSETS
  
  desc "Build mosaic manifest"
  file MOSAIC_MANIFEST => ASSETS do |t|
    raw = Exposure::BuildMosaicManifest.call(GALLERY)
    File.write(t.name, raw)
    puts "  » mosaic mainifest: -> #{t.name}"
  end

  OG_IMAGE = EXPOSURE_CONFIG.og_image
  WATERMARK_SRC = File.expand_path('assets/compiled-watermark-inverted.png')
  OG_MASTER_DIR = File.join(WWW_DIR, 'assets')
 
  OG_SERIES_SRC = File.expand_path('assets/og_series.svg')
  OG_SERIES_TRG = SERIES
    .map{[ File.join(OG_MASTER_DIR, 'series', it.slug, OG_IMAGE), it.title.upcase ]}
    .to_h 
    # .tap{ pp it }

  def make_png(source, target)
    tmp_png = "tmp.png"
    system("rsvg-convert -w 1200 -h 630 #{source} -o #{tmp_png}")
    system("magick #{tmp_png} \\( #{WATERMARK_SRC} -negate \\) -gravity south -geometry +0+40 -composite #{target}")
    FileUtils.rm_f(tmp_png)
  end

  def make_series_png(source, target, text)
    tmp_svg = "tmp.svg"
    svg_content = File.read(source)
    modified_svg = svg_content.gsub("SERIES TITLE", text)
    File.write(tmp_svg, modified_svg)
    make_png(tmp_svg, target)
    FileUtils.rm_f(tmp_svg)
  end

  OG_SERIES_TRG.each do |filename, title|
    
    # Define a file task where the target PNG depends on the source SVG template
    file filename => [OG_SERIES_SRC] do |t|
      # 1. Ensure the parent directory exists (e.g., www/assets/vaseline/)
      FileUtils.mkdir_p(File.dirname(t.name))
      
      # 2. Generate the PNG using the 'title' variable available from the outer loop closure
      make_series_png(OG_SERIES_SRC, t.name, title)
      puts "  » make series og_image: #{t.name}"
    end 
  end 

  # pp (SERIES_FULL.keys + SERIES_THUMB.keys)
  desc "Import exposure images"
  task :sync => ([GALLERY_ASSETS_DIR, MOSAIC_MANIFEST] +
    SERIES_FULL.keys +
    SERIES_THUMB.keys +
    OG_SERIES_TRG.keys
  )

  desc "Clean staged exposure images"
  task :clean do
    FileUtils.rm_rf SERIES_DIR
    File.delete(SERIES_INDEX) if File.exist?(SERIES_INDEX)
  end

end
