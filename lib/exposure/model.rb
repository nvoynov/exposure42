require_relative 'basic'
require_relative 'config'

module Exposure
  module Model
  
    # Gallery as collection of Series
    class Gallery < Data.define(:series)
      def initialize(series:)
        series = series
          .sort_by(&:latest_layout_asset)
          .reverse
        super(series:)
      end

      # Add this inside your Exposure::Gallery data structure class
      # @param count [Integer] total images needed for the main wall collage
      # @return [Array<String>] collection of unique absolute paths to master files
      def random_master_sources(count: 12)
        # Gather all master paths from non-hidden series
        all_sources = series.reject(&:hidden?).flat_map(&:og_master_sources)
  
        # Shuffle and return unique assets up to the required budget
        all_sources.uniq.shuffle.first(count)
      end

      def full_webp_targets
        series
          .flat_map(&:media_assets_full)
          .reduce({}, :merge)
      end
      
      def thumb_webp_targets
        series
          .flat_map(&:media_assets_thumb)
          .reduce({}, :merge)
      end

    end

  end
end
