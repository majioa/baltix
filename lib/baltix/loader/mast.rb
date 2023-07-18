module Baltix::Loader::Mast
   PROPS = {
      name: :name,
      version: :version,
      date: :date,
      authors: :authors,
      email: ->(this) do
         /(?<email>[^\s<]+@[^\s>]+)/ =~ this["contact"]
         email
      end,
      summary: :summary,
      description: :description,
      homepage: :"resources.home", #->(this) { this["resources"]["home"] }
      "metadata.homepage_uri": [
         :"resources.code",
         ->(this) { this['resources'].select {|x| x['type'] == 'home'}.first['uri'] if this['resources'].is_a?(Array) }
      ],
      "metadata.allowed_push_host": "https://rubygems.org",
      "metadata.source_code_uri": [
         :"resources.repo",
         ->(this) { this['resources'].select {|x| x['type'] == 'code'}.first['uri'] if this['resources'].is_a?(Array) }
      ],
      files: ->(this) { this["manifest"].grep(/^[^#]/) },
      bindir: "bin",
      executables: ->(this) { this["manifest"].grep(/^bin\//).map {|b| b.split("/").last } },
      require_paths: ["lib"],
      extra_rdoc_files: ->(this) { this["manifest"].grep(/\.(rdoc|md)$/) },
      licenses: ->(this) do
         if license = this["manifest"].grep(/LICENSE/).first
            lic = IO.read(license).split("\n")
            if type = lic.reduce(nil) { |r, l| r || /(?<type>Apache|MIT)/ =~ l && type }
               version = lic.reduce(nil) { |r, l| r || /Version (?<version>[\d\.]+)/ =~ l && version }
               [[ type, version ].compact.join("-") ]
            end
         end
      end,
      test_files: ->(this) { this["manifest"].grep(/^(test|spec|feature)\//) },
      required_ruby_version: nil,
      _add_development_dependency: ->(this) do
         if this['requires']
            this["requires"].map { |line| [/^(?<req>[^\s(]+)/.match(line)["req"]] }
         end
      end,
      _add_dependency_with_type: ->(this) do
         if this['requirements']
            this["requirements"].map do |dep|
               [dep['name'], dep['development'] ? :development : :runtime, [transform_version(dep['version'])].compact]
            end
         end
      end
   }

   def value_for value_in, data_in
      case value_in
      when Symbol
         value_in.to_s.split(".").reduce(data_in) {|r, n|  r.is_a?(Hash) || r.is_a?(Array) && n.is_a?(Integer) ? r[n] : nil }
      when Proc
         value_in[data_in]
      when NilClass
      when Array
         value_in.reduce(nil) { |r, v| r || value_for(v, data_in) }
      else
         value_in
      end
   end

   def manifest file_in
      spec = nil
      dir = File.dirname(file_in)
      file1 = File.join(dir, "meta", "package")
      file2 = File.join(dir, "meta", "profile")
      file3 = File.join(dir, ".index")

      if File.file?(file1) && File.file?(file2) || File.file?(file3)
         spec=
         Dir.chdir(dir) do
            Gem::Specification.new do |s|
               data =
                  if File.file?(file1) && File.file?(file2)
                     Kernel.yaml_load(IO.read(file1)).merge(
                     Kernel.yaml_load(IO.read(file2))).merge(
                        "manifest" => IO.read(file_in).split("\n"))
                  else
                     Kernel.yaml_load(IO.read(file3)).merge(
                        "manifest" => IO.read(file_in).split("\n"))
                  end

               PROPS.each do |name, value_in|
                  if value = value_for(value_in, data)
                     method_name = /^(?:_(?<mname>[^\.]+)|(?<subname>[^\.]+\..+)|.*)/ =~ name.to_s
                     if mname
                        if value.is_a?(Array)
                           value.each { |v| s.send(mname, *v) }
                        else
                           s.send(mname, value)
                        end
                     elsif subname
                        path = subname.split(".")
                        path[0..-2].reduce(s) {|r, n| r.send(n) }.send(:[]=, path[-1], value)
                     else
                        s.send("#{name}=", value)
                     end
                  end
               end
            end
         end

         file = Tempfile.new(spec.name)
         file.puts(spec.to_ruby)
         file.close
         res = app_file(file.path)
         file.unlink
         res
      end
   rescue Exception => e
      $stderr.puts "WARN [#{e.class}]: #{e.message}"
   end

   class << self
      def transform_version version
         if version
            /(?<number>[\d]+)(?<approx>[~><=])?/ =~ version
            part1 =
               case approx
               when '~'
                  '~> '
               when '>'
                  '>= '
               when '<'
                  '<= '
               when '='
                  '= '
               end

            [part1, number].join(' ')
         end
      end
   end
end
