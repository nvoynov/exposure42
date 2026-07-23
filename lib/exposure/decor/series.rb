require_relative 'asset'

module Exposure
  module Decor
  
    # Series decorator for Flatplan::Model::SeriesPublication
    class Series < Base
      attr_reader :directory_path

      # Custom initializer accepting the physical directory context
      # @param obj [Flatplan::Model::SeriesPublication]
      # @param directory_path [String]
      def initialize(obj, manifest_path:)
        super(obj)
        @manifest_name  = File.basename(manifest_path)
        @directory_path = File.dirname(manifest_path)
      end

      def hidden?
        @manifest_name == config.hidden_manifest_name
      end
  
      # @return [String]
      def slug
        title.to_s.downcase.strip
          .gsub(/[^a-z0-9\s_-]/, '')
          .gsub(/[\s_-]+/, '-')
      end

      # @return [Array<LayoutAsset>]
      def media_assets
        @media_assets ||= sections
          .inject([]) { |memo, e| memo + e.media_assets }
          .map{ Asset.new(it) }
      end

      # @return [Flatplan::Model::LayoutAsset]
      def latest_layout_asset
        media_assets.map(&:captured_at).max
      end

      def target_assets
        @target_assets = File.join(config.target_series_dir, slug)
      end

      def media_assets_full
        @media_assets_full ||= media_assets.map do |e|
          source = e.source_filename(directory_path)
          target = e.target_full_name(target_assets)
          [ target, source ]
        end.to_h
      end
    
      def media_assets_thumb
        @media_assets_thumb ||= media_assets.map do |e|
          source = e.source_filename(directory_path)
          target = e.target_thumb_name(target_assets)
          [ target, source ]
        end.to_h
      end

    end
  end
end
