module Baltix::Space::Spec
   class << self
      def load_from source_in
         spec = Baltix::Spec.load_from(source_in)

         Baltix::Space.new(spec: spec)
      end
   end
end
