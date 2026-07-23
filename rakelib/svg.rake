# # SVG compiler
# require_relative 'helper'

# namespace :svg do
#   OG_IMAGE = EXPOSURE_CONFIG.og_image

#   WATERMARK_SRC = File.expand_path('assets/compiled-watermark-inverted.png')
#   OG_MASTER_SRC = File.expand_path('assets/og_index.svg')
#   OG_MASTER_DIR = File.join(WWW_DIR, 'assets')
#   OG_MASTER_TRG = File.join(OG_MASTER_DIR, OG_IMAGE)
 
#   OG_SERIES_SRC = File.expand_path('assets/og_series.svg')
#   OG_SERIES_TRG = GALLERY.series.reject(&:hidden?)
#     .map{[ File.join(OG_MASTER_DIR, it.slug, OG_IMAGE), it.title ]}
#     .to_h 
#     # .tap{ pp it }

#   def make_png(source, target)
#     tmp_png = "tmp.png"
#     system("rsvg-convert -w 1200 -h 630 #{source} -o #{tmp_png}")
#     system("magick #{tmp_png} \\( #{WATERMARK_SRC} -negate \\) -gravity south -geometry +0+40 -composite #{target}")
#     FileUtils.rm_f(tmp_png)
#   end

#   def make_series_png(source, target, text)
#     tmp_svg = "tmp.svg"
#     svg_content = File.read(source)
#     modified_svg = svg_content.gsub("SERIES TITLE", text)
#     File.write(tmp_svg, modified_svg)
#     make_png(tmp_svg, target)
#     FileUtils.rm_f(tmp_svg)
#   end
    
#   task :series, [:title, :output_name] do |t, args|
#     series_title = args[:title] || "SERIES TITLE"
#     output_name  = args[:output_name] || "series_output.png"
#     make_series_png(OG_SERIES_SRC, output_name, series_title)
#   end 

# end
