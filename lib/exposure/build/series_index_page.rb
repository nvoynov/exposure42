require_relative 'base'

module Exposure
  module Build

    class SeriesIndexPage < Base

      # Centralized configuration header footprint to decouple metadata from core logic
      INDEX_METADATA_HEADER = <<~MARKDOWN
        ---
        title: Series
        description: Personal photography journeys and visual narratives exploration.
        ---
      MARKDOWN

      # Main execution gateway
      # @param gallery [Exposure::Gallery] the populated object model registry
      def call(gallery)
        # 1. Initialize layout stream using the isolated metadata constant anchor
        index_content = INDEX_METADATA_HEADER.dup
      
        # Open the global catalog container using native Pandoc Fenced Divs
        index_content << "\n::: {.collections-sketchbook}\n"
        # 2. Iterate through public series tracks only
        gallery.series.reject(&:hidden?).each do |series|
          folder_slug = series.slug
          cover_assets = series.media_assets.first(5)
          series_url = "/series/#{series.slug}.html"
        
          # We drop raw HTML wrapper entirely and use native Pandoc Div mapping.
          # This keeps the Flexbox DOM structure pristine and unbroken.
          index_content << <<~MARKDOWN
          
            ::: {.album-cloud-canvas}
          
            <a href="#{Build.root_path}#{series_url}" aria-label="Open #{series.title}" style="display:block;width:100%;height:100%;text-decoration:none;">
          
            ::: {.cloud-photos-wrapper}
            #{build_collage_markup(series)}
            :::
          
            ::: {.cloud-title-block}
            ### #{series.title}
            :::
          
            </a>
          
            :::
          MARKDOWN
        end
      
        # Close the global catalog layout container
        index_content << "\n:::\n"
      end

      private

      # Compiles layout assets into pure, readable native Pandoc Markdown photo entries
      # Wraps each image inside an explicit fenced div blocks grid matrix
      def build_collage_markup(series)
        slots = %w[pic-base pic-offset-one pic-offset-two pic-offset-three pic-offset-four]
        assets = series.media_assets.shuffle.take(5)
        assets.map.with_index do |asset, index|
          slot_class = slots[index] || "pic-base"
          # decorated = Decor::Asset.new(asset)
          filename = asset.target_thumb_name(series.target_assets)
        
          <<~MARKDOWN
            ::: {.cloud-pic .#{slot_class}}
            ![](#{Build.root_path}#{filename})
            :::
          MARKDOWN
        end.join("\n")
      end
      
    end
  end
end
