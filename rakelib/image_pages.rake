# rakelib/image_pages.rake
require 'fileutils'
require './lib/rawww'

namespace :pages do
  desc "Generate dynamic Markdown nodes for individual images (Shareable Nodes)"
  task :image_nodes do
    puts "  » pages: Generating shareable image markdown nodes..."
    
    # Filter active photography series context registries
    active_series = GALLERY.series.reject(&:hidden?)
    config = Rawww::Config.instance
    base_domain = config.site_url.chomp('/')

    active_series.each do |series|
      # Define target folder path for this specific series (e.g., src/series/vaseline/)
      series_src_dir = File.join(Rawww::SOURCE_DIR, 'series', series.slug)
      FileUtils.mkdir_p(series_src_dir)
      config = Rawww::Config.instance
      
      series.media_assets.each do |asset|
        filename = "#{File.basename(asset.filename, '.*')}.webp"
        slug_name = File.basename(filename, '.*')
        
        # Define target .md file path (e.g., src/series/vaseline/P1001495.md)
        md_target_path = File.join(series_src_dir, "#{slug_name}.md")

        # Basic human-readable title generation pattern
        calculated_title = slug_name.gsub(/[-_]/, ' ').capitalize

        # Resolve unique Og:Image absolute URL targeting the production environment location
        # Matches your asset pipeline directory paths perfectly
        base_domain = config.site_url.chomp('/')
        og_image_url = "#{base_domain}#{config.site_root}/assets/series/#{series.slug}/full/#{filename}"
        
        # --- THE REDIRECT ROUTING TRIGGER LAYER ---
        # Inline JavaScript tag template that instantly intercepts browser navigation
        # Uses standard relative mapping to escape the nested folder layout context
        redirect_script = "<script>window.location.replace(\"../#{series.slug}.html?img=#{slug_name}\");</script>"

        # Compile front-matter and payload structures into clean markdown strings
        # We append the redirect script directly into 'header-includes' array context
        md_content = <<~MARKDOWN
          ---
          title: "#{calculated_title} | Fine-Art Print Specification"
          layout: image_node
          slug: #{slug_name}
          og_image: "#{og_image_url}"
          header-includes:
            - '#{redirect_script}'
          ---

          ::: {.image-node-presenter-fallback}
          # #{calculated_title}
          
          This photographic print node reference token code is: `#{filename}`.
          
          ![#{calculated_title}](../../assets/series/#{series.slug}/full/#{filename})
          
          *Fine-Art limited editions printing metadata module placeholder.*
          :::
        MARKDOWN

        # Write file cleanly to disk context
        File.write(md_target_path, md_content)
      end
    end
    puts "  » pages: Shared markdown nodes compilation completed successfully."
  end

  desc "Clean dynamically generated image markdown nodes from src/"
  task :clean do
    active_series = GALLERY.series.reject(&:hidden?)
    active_series.each do |series|
      series_src_dir = File.join(Rawww::SOURCE_DIR, 'series', series.slug)
      if Dir.exist?(series_src_dir)
        FileUtils.rm_rf(series_src_dir)
        puts "  » pages: Pruned generated source directory context: #{series_src_dir}"
      end
    end
  end
end

# Tie cleanup tracks to your core engine lifecycles hooks
task :clean => 'pages:clean'
