require_relative '../basic'
require_relative '../model'
require_relative '../decor'

module Exposure
  module Build

    class Base < ::Rawww::Build::Base
      def_delegator :'Exposure::Config', :instance, :exposure_config
    end   

    def self.root_path
      config = Rawww::Config.instance
      production = ENV['RAWWW_PRODUCTION'] == 'true'
      production ? config.production_root_path : config.root_path
    end
    
  end
end
