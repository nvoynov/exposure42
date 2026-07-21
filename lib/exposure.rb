require_relative 'exposure/basic'
require_relative 'exposure/config'
require_relative 'exposure/model'
require_relative 'exposure/decor'
require_relative 'exposure/build'
require_relative 'exposure/magick'

module Exposure
  extend ::Basic::AliasMembers

  alias_members Build, prefix: 'Build'
end
