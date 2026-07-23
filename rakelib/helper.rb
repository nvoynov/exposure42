require './lib/rawww'
require './lib/exposure'

CONFIG  = Rawww::Config.instance
EXPOSURE_CONFIG = Exposure::Config.instance
GALLERY = Exposure::BuildGallery.call(EXPOSURE_CONFIG.master_series_dir)

SRC_DIR = 'src'
WWW_DIR = Rawww::PUBLIC_DIR

# if __FILE__ == $0
 
#   pp GALLERY.full_webp_targets, GALLERY.thumb_webp_targets
# end 
