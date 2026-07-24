require_relative 'base'

module Exposure
  module Build
   
    # Series Page Builder
    # class SeriesPage < Base      
    class SeriesPage < ::Flatplan::Presenter::PandocManifestSerializer
      def call(pub)
        raw = super(pub)
        raw << LIGHTBOX % {root: rawww.site_root}
        raw#.tap{ puts it }
      end
      
      protected
      
      # add page_type
      def render_yaml_front_matter(publication)
        og_image = File.join(publication.target_assets, exposure.og_image)
        super(publication)
          .lines
          .insert(-2, "page_type: article\n" ) 
          .insert(-2, "og_image: #{og_image}\n")
          .join
      end

      LIGHTBOX = <<~HTML
        <script src="%{root}/assets/js/lightbox.js" defer></script>
      HTML

      def serialize_image_tag(asset)
        decor = Decor::Asset.new(asset)
        filename = decor.target_thumb_name(@publication.target_assets)
        alt = '' # " alt=\"#{asset.alt}\""
        "![](#{rawww.site_root}#{filename}#{alt})"
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

      def rawww = @rawww ||= Rawww::Config.instance
      def exposure = @exposure ||= Exposure::Config.instance
    end
  end
end
