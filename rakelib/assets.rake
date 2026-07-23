require 'fileutils'
require './lib/rawww'

namespace :assets do
  # 1. Collect only existing static files (CSS, JS, favicon, etc.)
  # Explicitly ignore any dynamic full/thumb image directories
  ASSET_SOURCES = FileList['src/assets/**/*']
    .exclude(%r{/(full|thumb)/})
    .reject { |f| File.directory?(f) }

  # 2. Map source paths from 'src/' into the public directory (e.g., 'www/')
  ASSET_TARGETS = ASSET_SOURCES.pathmap("%{^src/,#{Rawww::PUBLIC_DIR}/}p")

  desc "Copy static assets (CSS, JS, images, favicon) to the build directory"
  task :copy => ASSET_TARGETS

  # 3. Secure rule with a strict dynamic prerequisite check
  # It intercepts only targets that actually map back to an existing file in 'src/assets/'
  rule(%r{^#{Rawww::PUBLIC_DIR}/assets/} => [
    ->(t_name) {
      source = t_name.sub(/^#{Rawww::PUBLIC_DIR}/, 'src')
      
      # Stop-word: if the target is a generated webp image, ignore it here.
      # This prevents conflict with manifest.rake rules.
      if t_name =~ %r{/(full|thumb)/.*webp$}
        ""
      elsif File.exist?(source)
        source
      else
        "" # Return empty string so Rake knows this rule doesn't handle this file
      end
    }
  ]) do |t|
    # Guard against empty source definitions
    next if t.source.empty?

    FileUtils.mkdir_p(File.dirname(t.name))
    FileUtils.cp(t.source, t.name)
    puts "  » copy: #{t.source} -> #{t.name}"
  end

  desc "Clean compiled assets"
  task :clean do
    target_dir = File.join(Rawww::PUBLIC_DIR, 'assets')
    FileUtils.rm_rf(target_dir) if Dir.exist?(target_dir)
    puts "  » cleaned: assets and branding nodes"
  end
end
