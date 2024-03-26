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

   def self.main
      @main ||= TOPLEVEL_BINDING.eval('self')

   end
end

{
  :Hoe => "hoe",
  :Olddoc => "olddoc",
  :Wrongdoc => "olddoc",
  :Bones => "bones",
  :Jeweler => "jeweler",
}.each do |mod, req|
   unless (mod.constantize rescue nil)
      Kernel.autoload(mod, File.dirname(__FILE__) + "/baltix/extensions/#{req}")
   end
end
