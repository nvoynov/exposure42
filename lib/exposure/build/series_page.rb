module Exposure
  module Build
   
    # Inherit basic serializer
    # class SeriesSerializer < ::Flatplan::Presenter::PandocManifestSerializer
    # end

    # Series Page Builder
    # class SeriesPage < Base      
    class SeriesPage < ::Flatplan::Presenter::PandocManifestSerializer
        
      # add page_type
      def render_yaml_front_matter(pub)
        config = Config.instance
        og_image = File.join(pub.target_assets, config.og_image)
        super(pub)
          .lines
          .insert(-2, "page_type: article\n" ) 
          .insert(-2, "og_image: #{og_image}\n")
          .join
      end

      def serialize_image_tag(asset)
        # "!\[#{asset.caption}\]\(#{asset.filename}\)"
        decorated = Decor::Asset.new(asset)
        filename = decorated.target_thumb_name(@publication.target_assets)
        alt = '' # " alt=\"#{asset.alt}\""
        "![](#{ROOT_PATH}#{filename}#{alt})"
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
