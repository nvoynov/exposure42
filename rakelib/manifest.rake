# rakelib/manifest.rake

require 'fileutils'
require 'pathname'
require_relative 'helper'

namespace :manifest do

  SERIES_DIR = File.join(SRC_DIR, 'series')
  SERIES_INDEX = SERIES_DIR + '.md'
  
  desc "Build series index"
  file "#{SERIES_DIR}.md" do |t|
    raw = Exposure::BuildSeriesIndexPage.call(GALLERY)
    File.write(t.name, raw)
  end

  # Create series page builder
  BUILD_SERIES_PAGE = Exposure::BuildSeriesPage.new

  mk_series_page = proc do |e, hash|
    key = File.join(SERIES_DIR, e.slug + '.md')
    hash[key] = e
  end

  SERIES_PAGES = SERIES.each_with_object({}, &mk_series_page)
  
  desc "Build series pages"
  rule(%r{^#{SERIES_DIR}/.*md$}) do |t|
    FileUtils.mkdir_p File.dirname(t.name)
    raw = BUILD_SERIES_PAGE.call(SERIES_PAGES[t.name])
    File.write(t.name, raw)
  end

  desc "Build gallery manifest"
  task :sync => ([SERIES_INDEX] + SERIES_PAGES.keys)
  
  desc "Clean staged manifest source"
  task :clean do
    FileUtils.rm_rf SERIES_DIR
    File.delete(SERIES_INDEX) if File.exist?(SERIES_INDEX)
  end
end
