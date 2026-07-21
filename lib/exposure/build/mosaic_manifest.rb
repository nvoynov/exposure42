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
        gallery_data = {}
        gallery.series.each do |series|
          folder_slug = File.basename(series.directory_path)
        
          gallery_data[series.slug] = {
            "album_slug" => series.slug,
            "photos" => series.media_assets.map { |asset|
              filename = "#{File.basename(asset.filename, '.*')}.webp"
              {
                "filename" => filename,
                "title" => File.basename(filename, ".*").gsub(/[-_]/, " ").capitalize
              }
            }
          }
        end

        manifest_payload = {
          "thumb_dir" => exposure_config.image_thumb_dir,
          "series" => gallery_data.values
        }

        # TODO: having final manifest.rake, maybe JSON here and return Hash
        #       let mainifest.rake to decide how an where to store it
        JSON.pretty_generate(manifest_payload)

        # output_dir = File.join(config.www_dir, "assets")
        # FileUtils.mkdir_p(output_dir)      
        # destination_path = File.join(output_dir, "manifest.json")
        # File.write(destination_path, JSON.pretty_generate(manifest_payload))
      end
    end
  end
end
