begin
   require 'pry'
rescue LoadError
end

require 'ostruct'

require "baltix/version"
require "baltix/extensions"

module Baltix
   ::OpenStruct.include(Extensions::OpenStruct)
   ::Hash.include(Extensions::Hash)
end
