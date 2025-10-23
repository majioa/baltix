require 'rake'

require 'baltix'
require 'baltix/log'

module Baltix::Loader
   include Baltix::Log

   module Certain
      include Baltix::Log
      include Rake::DSL

      attr_reader :object_hash, :object_ids

      alias_method :require_orig, :require

      def require path, *args
         return true if require_embedded

         paths = $:.map {|x| patha = (x =~ /^\// ? x : File.join(Dir.pwd, x)) }.map {|p| File.expand_path(File.join(p, path + "*")) }
         files = paths.map {|x| Dir[x] }.flatten.uniq.select {|x| x =~ %r{#{@dir}}}

         @requires.push(path)
         if files.empty?
            require_orig(path, *args)
         else
            file = files.first
            _file = File.basename(file)
            code = File.read(file, mode: 'r:UTF-8:-')
            if @stack.include?(file)
               return false
            else
               begin
                  @stack.push(file)
                  instance_eval(code, _file)
               ensure
                  @stack.pop
               end
            end
         end
      end

      def require_embedded path
         unless File.absolute_path?(path)
            begin
               # try loading extension
               require_relative('extensions/' + path)
            rescue LoadError
            else
               return true
            end
         end
      end

      def method_missing name, *parms, **parmh
         execs = self.instance_variables.include?(:@execs) ? self.instance_variable_get(:@execs) : []
         execs << [name, parms, parmh]

         self.instance_variable_set(:@execs, execs)
      end

      #alias_method :orig_gem, :gem
      #define_method :gem do |*args|
      def gem name, *args
         gems = self.instance_variables.include?(:@gems) ? self.instance_variable_get(:@gems) : []

         gems.concat([name => args])
         self.instance_variable_set(:@gems, gems)

         true
      end

      def store_object_hash type_hash
         object_hash =
            type_hash.map do |(klass, types)|
               objects = types.split(',').map do |type|
                  begin
                     ObjectSpace.each_object(type.constantize).map { |h| h }
                  rescue NameError
                     []
                  end
               end.flatten

               [klass, objects]
            end.to_h

         if @object_hash
            @object_ids = object_hash.map do |(k, oh)|
               [k, oh.map {|h| h.__id__ } - @object_hash[k].map {|h| h.__id__ }]
            end.to_h
         end

         @object_hash = object_hash
      end

      def load_file file, dir, type_hash
         # NOTE this forces not to share namespace but avoid exception when calling
         # main space methods, see Rakefile of racc gem
         # also named module is required instead of anonymous one to allow root level defined methods access
         @dir = dir
         @stack = []
         @requires = []
         store_object_hash(type_hash)
         value = nil

         begin
            push
            Dir.chdir(File.dirname(file)) do
               _file = File.basename(file)
               code = File.read(file, mode: 'r:UTF-8:-')

               value =
                  begin
                     # evaluation required not to lost loaded object,
                     # the instance_eval is used in favor of eval to avoid lost predefined vars
                     # like for chef-utils gem
                     stderr = $stderr.dup
                     stdout = $stdout.dup
                     instance_eval(code, _file)
                  rescue Exception => e
                     # thrown for setup gem
                     load(File.basename(file), true)
                  ensure
                     $stderr = stderr
                     $stdout = stdout
                  end
            end
         rescue Exception => e
            raise e
         ensure
            debug("value: #{value.inspect}")
            pop
            store_object_hash(type_hash)
         end

         self
      rescue Exception => e
         debug("[#{e.class}]: #{e.message}\n\t#{e.backtrace.join("\n\t")}")

         self
      end

      def push
         @paths = $:.dup
         debug("Stored paths are: " + @paths.join("\n\t"))
      end

      def pop
         debug("Subtract paths: " + ($: - @paths).join("\n\t"))
         # NOTE this sequency of merging is required to correct loading libs leads
         # to show warning and break building rdoc documentation
         $:.replace(@paths | $:)
         debug("Replaced paths with: " + $:.join("\n\t"))
      end
   end

   def self.extended_list
      @extended_list ||= []
   end

   def self.extended kls
      extended_list << kls
   end

   def type_hash
      @type_hash ||=
         Baltix::Loader.extended_list.map do |kls|
            type =
               begin
                  kls.const_get('TYPE')
               rescue
                  nil
               end

            [kls, type]
         end.select {|(_, type)| type }.to_h
   end

   def pre_loaders
      @pre_loaders ||=
         Baltix::Loader.extended_list.map do |kls|
            begin
               kls.const_get('PRELOAD_MATCHER')&.map do |k, v|
                  [k, v.is_a?(Symbol) && kls.singleton_method(v) || v]
               end.to_h || {}
            rescue
               {}
            end
         end.reduce {|res, hash| res.merge(hash) }
   end

   def mods
      @@mods ||= {}
   end

   def load_file file, dir
      debug("Loading file: #{file}")
      stdout = $stdout
      stderr = $stderr

      tmpio = Tempfile.new('loader')
      $stdout = $stderr = tmpio.dup

      pre_loaders.each do |(m, preload_method)|
         if file =~ m
            args = [file][0...preload_method.arity]
            preload_method[*args]
         end
      end

      module_name = "M" + Random.srand.to_s
      mod_code = <<-END
         module #{module_name}
            extend(::Baltix::Loader::Certain)
         end
      END

      mod = module_eval(mod_code)
      mod.load_file(file, dir, type_hash)
      tmpio.rewind

      res = OpenStruct.new(mod: mod, log: tmpio.readlines, errlog: tmpio.readlines)
      mod.instance_variables.map {|x| x[1..-1] }.reduce(res) do |r, name|
         r.merge({name => mod.instance_variable_get("@#{name}")})
      end
   rescue Exception => e
      warn(e.message)

      OpenStruct.new(mod: mod, object_hash: {}, log: tmpio.readlines, errlog: tmpio.readlines, object_ids: [])
   ensure
      $stderr = stderr
      $stdout = stdout
   end

   def app_file file, dir = Dir.pwd, &block
      mods[file] ||= load_file(file, dir)

      mod = mods[file].dup
      objects = mod.object_ids[self]&.map {|id| ObjectSpace._id2ref(id) }

      debug("Object ids for '#{file}' are: #{mod.object_ids[self].inspect}")
      debug("Objects for '#{file}' are: #{objects.inspect}")

      if block_given?
         objects = [yield(objects)].flatten.compact
      end
      mod.objects = objects || []

      mod
   end
end
