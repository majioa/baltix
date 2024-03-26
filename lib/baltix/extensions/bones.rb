# Bones based gemspec detection module
# Sample gems are: bones, loquacious, little-plugger
#
module Bones
   class Config
      class Gem
         def _spec
            @_spec ||= ::Gem::Specification.new nil, version
         end

         def version
            IO.read("version.txt").strip
         rescue Errno::ENOENT
         end
      end

      def gem
         @gem ||= Gem.new
      end

      def name= value
         @name = value
      end
   end

   class Ann
      def paragraphs _
      end

      def text _
      end
   end

   class Gem
      def extras
         @extras ||= {}
      end
   end

   class Notes
      def exclude _
      end
   end

   class Spec
      def opts
         Bones.config.gem._spec.rdoc_options
      end
   end

   module Methods
      def name value = nil
         Bones.config.gem._spec.name = value if value
      end

      def authors value
         Bones.config.gem._spec.authors << value
      end

      def email value
         Bones.config.gem._spec.email = value
      end

      def url value
         Bones.config.gem._spec.homepage = value
      end

      def license value
         Bones.config.gem._spec.license = value
      end

      def version value
         Bones.config.gem._spec.version = value
      end

      def readme_file value
         readme = IO.read(value)
         /(?<=== DESCRIPTION:\n)(?<desc>.*?)(?>=== )/m =~ readme
         Bones.config.gem._spec.files << value
         Bones.config.gem._spec.extra_rdoc_files << value
         Bones.config.gem._spec.summary = desc.strip.split("\n").first
         Bones.config.gem._spec.description = desc.strip
      end

      def use_gmail
      end

      def ensure_in_path *args
         true
      end

      def depend_on name, version = nil, options = {}
         if options[:development]
            Bones.config.gem._spec.add_development_dependency name, version
         else
            Bones.config.gem._spec.add_dependency name, version
         end
      end

      def spec
         @spec ||= Spec.new
      end

      def notes
         @notes ||= Notes.new
      end

      def gem arg = nil, arg1 = nil
         if arg
            super
         else
            @gem ||= Gem.new
         end
      end

      def ann
         @ann ||= Ann.new
      end

      def method_missing *args
        Kernel.puts args.inspect
         super
        binding.pry
      end
   end

   class << self
      def config
         @config ||= Bones::Config.new
      end

      def spec
         @config.gem._spec
      end
   end

   module Main
      def method_missing method_name, *args
         if Bones.respond_to?(method_name)
            Bones.send(method_name, *args)
         else
            super
         end
      end
   end
end

module Kernel
   def Bones name = nil
      self.extend(Bones::Methods)

      yield
   end
end
