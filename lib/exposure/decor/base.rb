require 'delegate'
require_relative '../basic'
require_relative '../config'

module Exposure
  module Decor
    class Base < SimpleDelegator
      include ConfigMixin
    end
  end
end
