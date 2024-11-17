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
   ::Object.include(Extensions::Object)
   ::OpenStruct.include(Extensions::OpenStruct)
   ::String.include(Extensions::String)
   ::Gem::Requirement.include(Extensions::GemRequirement)

   class << self
      def main
         @main ||= TOPLEVEL_BINDING.eval('self')
      end

      def load string
         if Gem::Version.new(Psych::VERSION) >= Gem::Version.new("4.0.0")
            YAML.load(string,
               aliases: true,
               permitted_classes: [
                  Baltix::Source::Fake,
                  Baltix::Source::Rakefile,
                  Baltix::Source::Gemfile,
                  Baltix::Source::Gem,
                  Baltix::Spec::Rpm,
                  Baltix::Spec::Rpm::Name,
                  Baltix::Spec::Rpm::Secondary,
                  Gem::Specification,
                  Gem::Version,
                  Gem::Dependency,
                  Gem::Requirement,
                  OpenStruct,
                  Symbol,
                  Time,
                  Date
               ])
         else
            YAML.load(string)
         end
      end
   end
end

{
  :Hoe => "hoe",
  :Echoe => "echoe",
  :Olddoc => "olddoc",
  :Wrongdoc => "olddoc",
  :Bones => "bones",
  :Jeweler => "jeweler",
}.each do |mod, req|
   unless (mod.constantize rescue nil)
      Kernel.autoload(mod, File.dirname(__FILE__) + "/baltix/extensions/#{req}")
   end
end
