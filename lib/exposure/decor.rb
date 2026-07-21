# lib/exposure/series.rb
require 'delegate'
require_relative 'basic'
require_relative 'config'

module Exposure
  # TODO: no sens place one decor in dedicated namespace
  
  # Series decorator for Flatplan::Model::SeriesPublication
  class Series < SimpleDelegator
    attr_reader :directory_path

    # Custom initializer accepting the physical directory context
    # @param obj [Flatplan::Model::SeriesPublication]
    # @param directory_path [String]
    def initialize(obj, manifest_path:)
      super(obj)
      @manifest_name  = File.basename(manifest_path)
      @directory_path = File.dirname(manifest_path)
    end

    # TODO: how wo manage hidden series?
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
      @media_assets ||= sections.inject([]) { |memo, e| memo + e.media_assets }
    end

    def media_assets_paths
      media_assets.map{ File.join(directory_path, it.filename) }
    end

    # @return [Flatplan::Model::LayoutAsset]
    def latest_layout_asset
      media_assets.map(&:captured_at).max
    end

    # Add this inside your Exposure::Series decorator class
    # @return [Array<String>] absolute paths to the first 5 original master images
    def og_master_sources
      media_assets.first(5).map do |asset|
        # Reconstruct the absolute path to the original file in the master gallery
        File.join(directory_path, asset.filename)
      end
    end

    private

    def config
      Config.instance
    end
  end
end
