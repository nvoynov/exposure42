module Exposure
  module Build
   
    # Inherit basic serializer
    class SeriesSerializer < ::Flatplan::Presenter::PandocManifestSerializer; end

    # Series Page Builder
    class SeriesPage < Base      

      def initialize
        @serializer = SeriesSerializer.new
      end
      
      # @param publication [Flatplan::Model::SeriesPublication]
      # @return [String] markdown string
      def call(publication)
        raw_markdown = @serializer.call(publication)        

        # Path remap: Converts raw tifs/jpgs directly to the structured configuration thumbs directory
        raw_markdown.gsub(/\(([^)]+)\.(tif|tiff|jpg|jpeg|png)\)/i) do
          base_name = $1
          "(../assets/images/#{publication.slug}/#{exposure_config.image_thumb_dir}/#{base_name}.webp)"
        end
      end
    end

    class SeriesSerializer 

      # add page_type
      def render_yaml_front_matter(pub)
        super(pub)
          .lines
          .insert(-2, "page_type: article\n") 
          .join
      end
      
      def serialize_image_metadata(asset)
        return "" if rand > 0.5

        print_paper = "Hahnemühle FineArt Paper"
        paper_size  = "21x31 cm"
        image_size  = "20x30 cm"

        attributes = []
        attributes << ".fine-art-imprint"
        attributes << "data-print-paper=\"#{print_paper}\""
        attributes << "data-print-paper-size=\"#{paper_size}\""
        attributes << "data-print-image-size=\"#{image_size}\""

        "{#{attributes.join(' ')}}"
      end
    end
  end
end
