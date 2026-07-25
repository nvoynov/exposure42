require 'json'
require_relative 'base'

module Exposure
  module Build
  
    # Service object responsible for compiling the frontend mosaic layout 
    # database manifest tracking public series photos and configuration values.
    class MosaicManifest < Base

      # Main execution gateway
      # @param gallery [Exposure::Gallery] the populated object model registry
      def call(gallery)
        gallery_data = gallery.series.map do |series|
          {
            "album_slug" => series.slug,
            "photos" => series.media_assets.map { |asset|
              { "filename" => "#{File.basename(asset.filename, '.*')}.webp" }
            }
          }
        end

        # Return a tight, zero-garbage database payload
        JSON.pretty_generate({ "series" => gallery_data })
      end
    end
  end
end
