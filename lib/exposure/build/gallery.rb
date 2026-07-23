require_relative 'base'

module Exposure
  module Build

    # Gallery builder orchestrating Flatplan manifest resolution
    class Gallery < Base

      def initialize
        super
        ::Flatplan.default!
      end
    
      # @param series_dir [String] path to the master series gallery collection
      # @return [Gallery]
      def call(series_dir)
        series = Dir.glob("#{series_dir}/**/#{exposure_config.public_manifest_name}")
        hidden = Dir.glob("#{series_dir}/**/#{exposure_config.hidden_manifest_name}")

        (series + hidden)
          .map(&method(:load_series)) # => Array<Series>
          .then{ Model::Gallery.new(series: it) }
          # .tap { pp it }
      end

      private

      # Loads the core Flatplan publication and immediately decorates it with filesystem metadata
      # @param manifest_path [String]
      # @return [Exposure::Series]
      def load_series(manifest_path)
        filename = File.basename(manifest_path)
        dir_path = File.dirname(manifest_path)
        publication = ::Flatplan::LoadPublication.call(
          directory_path: dir_path,
          manifest_name: filename)
      
        Decor::Series.new(publication, manifest_path:) # => decorated series
      end
    end
  end
end
