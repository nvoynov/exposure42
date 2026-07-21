require './lib/rawww'
require './lib/exposure'

CONFIG  = Rawww::Config.instance
EXPOSURE_CONFIG = Exposure::Config.instance
GALLERY = Exposure::BuildGallery.call(EXPOSURE_CONFIG.master_series_dir)

SRC_DIR = 'src'
WWW_DIR = Rawww::PUBLIC_DIR
