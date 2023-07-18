module Baltix::Space::Spec
   class << self
      def load_from source_in, options = nil
         space = Baltix::Space.new(options: options)
         spec = Baltix::Spec.load_from(source: source_in, space: space)
         space.spec = spec

         space
      end
   end
end
