# vim: noai:ts=3:sts=3:et:sw=3
# Actor spec
require 'baltix/spec'

module Baltix::Actor::Spec
   class << self
      def context_kind
         Baltix::Space
      end

      # +apply_to+ generates spec according to the provided setup
      #
      def apply_to space, template = nil
         spec = Baltix::Spec.find(space.spec_type)

         rendered = spec.render(space, template)

         if space.options.output_file
            File.open(space.options.output_file, "w") { |f| f.puts(rendered) }
         end

         rendered
      end
   end
end
