require 'tmpdir'
require_relative 'basic'

module Exposure

  class Magick < ::Basic::CliTool
    # Declaratively register the ImageMagick 7 binary executable
    executable :magick

    # Converts the source TIFF image to a full-size production WebP asset
    #
    # @param source [String] absolute or relative path to the source .tif file
    # @param destination [String] target output path for the compiled _full.webp
    # @param quality [Integer] WebP compression quality factor (0-100)
    def convert_to_full(source, destination, quality: 85)
      args = [
        source,
        "-colorspace", "sRGB",
        "-quality", quality.to_s,
        destination
      ]
      execute_command(*args)
    end

    # Converts the source TIFF image to a scaled thumbnail WebP asset preserving aspect ratio
    #
    # @param source [String] absolute or relative path to the source .tif file
    # @param destination [String] target output path for the compiled _thumb.webp
    # @param max_side [Integer] maximum bounding box dimension in pixels
    # @param quality [Integer] WebP compression quality factor (0-100)
    def convert_to_thumb(source, destination, max_side: 450, quality: 80)
      args = [
        source,
        "-colorspace", "sRGB",
        "-resize", "#{max_side}x#{max_side}>", # Scales down only if image is larger than bounding box
        "-quality", quality.to_s,
        destination
      ]
      execute_command(*args)
    end

    # 1. Individual Series OG Cover (Scattered Cards)
    def create_series_og_cover(images:, output:)
      raise ArgumentError, 'Requires 5 images' if images.length != 5
      config = Exposure::Configuration.instance
      # Directly read the configured path from exposure.yml without double wrapping
      wm = File.join(config.watermark_name)
      
      layers = [
        { dim: '430x430', rot: -6, pos: '+30+20' },
        { dim: '390x390', rot: 5,  pos: '+680+60' },
        { dim: '430x430', rot: -3, pos: '+110+250' },
        { dim: '410x410', rot: 4,  pos: '+690+230' },
        { dim: '540x540', rot: -1, pos: '+320+65' }
      ]

      temp_cards = []
      begin
        layers.each_with_index do |cfg, i|
          tmp = File.join(Dir.tmpdir, "og_c_#{i}.png")
          prepare_scattered_card(images[i], tmp, cfg[:dim], cfg[:rot], 7)
          temp_cards << tmp
        end
        
        # REMOVED duplicated 'magick' binary token from the arguments array
        cmd = ['-size', '1200x630', 'canvas:#FAFAFA']
        temp_cards.each_with_index { |p, i| cmd.concat([p, '-geometry', layers[i][:pos], '-composite']) }
        cmd.concat([wm, '-gravity', 'southeast', '-geometry', '+50+50', '-composite']) if File.exist?(wm)
        cmd.concat(['-strip', '-sampling-factor', '4:2:0', '-quality', '85', output])
        
        execute_command(*cmd)
      ensure
        temp_cards.each { |p| File.delete(p) if File.exist?(p) }
      end
    end

    # 2. Main Page OG Cover (4x3 Grid)
    def create_main_og_cover(images:, output:)
      raise ArgumentError, "Requires 12 images" if images.length != 12
      config = Exposure::Configuration.instance
      wm = File.join(config.watermark_name)
      
      # REMOVED duplicated 'magick' binary token from the arguments array
      cmd = ['-size', '1200x630', 'canvas:#FFFFFF']
      images.each_with_index do |img, i|
        cmd.concat(['(', img, '-resize', '300x210^', '-gravity', 'center', '-crop', '300x210+0+0', '+repage', ')', '-geometry', "+#{(i%4)*300}+#{(i/4)*210}", '-composite'])
      end
      cmd.concat([wm, '-gravity', 'southeast', '-geometry', '+40+40', '-composite']) if File.exist?(wm)
      cmd.concat(['-strip', '-sampling-factor', '4:2:0', '-quality', '85', output])
      
      execute_command(*cmd)
    end

    private

    def prepare_scattered_card(src, dst, dim, rot, border)
      # REMOVED duplicated 'magick' binary token from the arguments array
      execute_command(src, '-resize', dim, '-bordercolor', 'white', '-border', border.to_s, 
        '(', '+clone', '-background', 'rgba(0,0,0,0.15)', '-shadow', '60x4+2+4', ')',
        '+swap', '-background', 'transparent', '-layers', 'merge', '-rotate', rot.to_s, '+repage', dst)
    end
    
  end
end
