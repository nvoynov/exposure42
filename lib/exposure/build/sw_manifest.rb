require 'json'
require_relative 'base'

module Exposure
  module Build
  
    # Service object responsible for scanning the final production output directory 
    # and compiling a deterministic mtime manifest for granular Service Worker caching.
    class SwManifest < Base

      # @param dirpath [String] production output directory
      # @return [String] JSON manifest content
      def call(dirpath)
        manifest_payload = { "assets" => {} }
      
        # Dynamically locate every single generated physical file footprint within the web root
        production_files = Dir
          .glob("#{dirpath}/**/*")
          .select{ File.file?(it) }
      
        production_files.each do |file|
          # Convert absolute/relative disk paths straight to pristine web root keys (e.g., "/css/style.css")
          clean_key = file.sub(/^#{dirpath}/, "")
        
          # Capture the integer modification stamp as an unforgeable cache-busting token
          manifest_payload["assets"][clean_key] = File.mtime(file).to_i
        end
        # TODO: having final manifest.rake, maybe JSON here and return Hash
        #       let mainifest.rake to decide how an where to store it
        JSON.pretty_generate(manifest_payload)
      end
    end
  end
end
