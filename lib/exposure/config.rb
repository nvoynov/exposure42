require_relative '../basic'

module Exposure

  ConfigSchema = Data.define(
    :master_series_dir,
    :public_manifest_name,
    :hidden_manifest_name,
    :site_title,
    :site_author,
    :og_image,
    :mosaic_desktop_limit,
    :mosaic_mobile_limit,
    :image_full_quality,
    :image_thumb_quality,
    :image_thumb_max_side,
    :image_full_dir,
    :image_thumb_dir,
    :watermark_name
  ) do

    def initialize(
      master_series_dir:    '~/Pictures',
      public_manifest_name: 'PUBLIC.md',
      hidden_manifest_name: 'SERIES.md',
      site_title:           'Exposure',
      site_author:          'Author',
      og_image:             'og_image.jpg',
      mosaic_desktop_limit: 6,
      mosaic_mobile_limit:  5,
      image_full_quality:   85,
      image_thumb_quality:  80,
      image_thumb_max_side: 450,
      image_full_dir:       'full',
      image_thumb_dir:      'thumbs',
      watermark_name:       'watermark.png'
    )
      super(
        master_series_dir:,
        public_manifest_name:,
        hidden_manifest_name:,
        site_title:,
        site_author:,
        og_image:,
        mosaic_desktop_limit:,
        mosaic_mobile_limit:,
        image_full_quality:,
        image_thumb_quality:,
        image_thumb_max_side:,
        image_full_dir:,
        image_thumb_dir:,
        watermark_name:
      )
    end
  end

  class Config < ::Basic::Configuration
    manage ConfigSchema
  end

end
