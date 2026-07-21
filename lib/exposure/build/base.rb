require_relative '../basic'
require_relative '../model'
require_relative '../decor'

module Exposure
  module Build

    class Base < ::Rawww::Build::Base
      def_delegator :'Exposure::Config', :instance, :exposure_config
    end   
  end
end
