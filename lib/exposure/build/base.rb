require_relative '../basic'
require_relative '../model'
require_relative '../decor'

module Exposure
  module Build

    class Base < ::Rawww::Build::Base
      def_delegator :'Exposure::Config', :instance, :exposure_config
    end   

    ROOT_PATH =  
      [ Rawww::Config.instance, ENV['RAWWW_PRODUCTION'] == 'true'
      ].then{|rawww, production|
        production ? rawww.production_root_path : rawww.root_path
      }.freeze
  end
end
