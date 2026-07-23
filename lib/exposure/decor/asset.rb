require_relative 'base'

module Exposure
  module Decor
  
    # Asset decorator for Flatplan::Model::MeidaAsset
    #   it knows where to get and place the asset
    class Asset < Base
      def source_filename(prefix = '')
        File.join(prefix, filename)
      end
    
      def target_filename
        @target_filename ||= File.basename(filename, '.*') << '.webp'
      end

      def target_full_name(prefix = '')
        File.join(prefix, config.target_series_full, target_filename)
      end

      def target_thumb_name(prefix = '')
        File.join(prefix, config.target_series_thumb, target_filename)
      end
    end
  end
end
