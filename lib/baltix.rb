begin
   require 'pry'
rescue LoadError
end

require 'ostruct'

require "baltix/version"
require "baltix/extensions"
require 'baltix/i18n'
require 'baltix/deps'

module Baltix
   ::Kernel.extend(Extensions::Kernel)
   ::Object.include(Extensions::Object)
   ::OpenStruct.include(Extensions::OpenStruct)
   ::Hash.include(Extensions::Hash)
   ::Gem::Requirement.include(Extensions::GemRequirement)
end
