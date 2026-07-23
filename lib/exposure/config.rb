require_relative '../basic'

module Exposure

  ConfigSchema = Data.define(
    :master_series_dir,
    :public_manifest_name,
    :hidden_manifest_name,
    :target_series_dir,
    :target_series_full,
    :target_series_thumb,
    :og_image,
    :mosaic_desktop_limit,
    :mosaic_mobile_limit,
    :image_full_quality,
    :image_thumb_quality,
    :image_thumb_max_side,
    :watermark_name
  ) do

    def initialize(
      master_series_dir:    '~/Pictures',
      public_manifest_name: 'PUBLIC.md',
      hidden_manifest_name: 'SERIES.md',
      target_series_dir:    '/assets/series',
      target_series_full:   'full',
      target_series_thumb:  'thumbs',
      og_image:             'og_image.jpg',
      mosaic_desktop_limit: 6,
      mosaic_mobile_limit:  5,
      image_full_quality:   85,
      image_thumb_quality:  80,
      image_thumb_max_side: 450,
      watermark_name:       'watermark.png'
    )
      super(
        master_series_dir:,
        public_manifest_name:,
        hidden_manifest_name:,
        target_series_dir:,
        target_series_full:,
        target_series_thumb:,
        og_image:,
        mosaic_desktop_limit:,
        mosaic_mobile_limit:,
        image_full_quality:,
        image_thumb_quality:,
        image_thumb_max_side:,
        watermark_name:
      )
    end
  end

  class Config < ::Basic::Configuration
    manage ConfigSchema
  end

  module ConfigMixin
    def self.included(base)
      # for instance.config
      base.extend(Forwardable)
      base.def_delegator :'Exposure::Config', :instance, :config

      # for Class.config
      base.singleton_class.extend(Forwardable)
      base.singleton_class.def_delegator :'Exposure::Config', :instance, :config
    end
  end

end
