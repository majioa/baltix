class Baltix::Spec::Rpm::Parser
   MATCHER = /^Name:\s+([^\s]+)/i

   SCHEME = {
      name: {
         non_contexted: true,
         regexp: /^Name:\s+([^\s]+)/i,
         parse_func: :parse_name
      },
      version: {
         non_contexted: true,
         regexp: /Version:\s+([^\s]+)/i,
         parse_func: :parse_version,
         mode: :replace
      },
      epoch: {
         non_contexted: true,
         regexp: /Epoch:\s+([^\s]+)/i,
         mode: :replace
      },
      release: {
         non_contexted: true,
         regexp: /Release:\s+([^\s]+)/i,
         mode: :replace
      },
      summaries: {
         regexp: /Summary(?:\(([^\s:]+)\))?:\s+([^\s].+)/i,
         parse_func: :parse_summary,
         mode: :replace
      },
      licenses: {
         non_contexted: true,
         regexp: /License:\s+([^\s].+)/i,
         parse_func: :parse_license
      },
      group: /Group:\s+([^\s]+)/i,
      uri: /Url:\s+([^\s]+)/i,
      vcs: /Vcs:\s+([^\s]+)/i,
      packager: {
         non_contexted: true,
         regexp: /Packager:\s+(.*)\s*(?:<(.*)>)$/i,
         parse_func: :parse_packager
      },
      build_arch: /BuildArch:\s+([^\s]+)/i,
      patches: {
         non_contexted: true,
         regexp: /Patch(\d+)?:\s+([^\s]+)/i,
         parse_func: :parse_file
      },
      source_files: {
         non_contexted: true,
         regexp: /Source(\d+)?:\s+([^\s]+)/i,
         parse_func: :parse_file
      },
      build_pre_requires: {
         non_contexted: true,
         regexp: /(?:BuildPreReq|BuildRequires\(pre\)):\s+([\w\s<=>\.\-_]+)/i,
         parse_func: :parse_dep
      },
      build_requires: {
         non_contexted: true,
         regexp: /^BuildRequires:\s*([^#]+)/i,
         parse_func: :parse_dep
      },
      obsoletes: {
         regexp: /^Obsoletes:\s*([^#]+)/i,
         parse_func: :parse_dep
      },
      provides: {
         regexp: /^Provides:\s*([^#]+)/i,
         parse_func: :parse_dep
      },
      requires: {
         regexp: /^Requires:\s*([^#]+)/i,
         parse_func: :parse_dep
      },
      conflicts: {
         regexp: /^Conflicts:\s*([^#]+)/i,
         parse_func: :parse_dep
      },
      ignored_names: {
         non_contexted: true,
         regexp: /(^%ruby_ignore|--ignore=)\s*([^\s$]+)/i,
         parse_func: :parse_ignore
      },
      descriptions: {
         regexp: /^%description\s*([^\s].*)?/i,
         parse_func: :parse_description
      },
      secondaries: {
         non_contexted: true,
         regexp: /^%package\s+(.+)/i,
         parse_func: :parse_secondary
      },
      prep: {
         non_contexted: true,
         regexp: /^%prep/i,
         parse_func: :parse_plain_section
      },
      build: {
         non_contexted: true,
         regexp: /^%build/i,
         parse_func: :parse_plain_section
      },
      install: {
         non_contexted: true,
         regexp: /^%install/i,
         parse_func: :parse_plain_section
      },
      check: {
         non_contexted: true,
         regexp: /^%check/i,
         parse_func: :parse_plain_section
      },
      file_list: {
         regexp: /^%files\s*([^\s].*)?/i,
         parse_func: :parse_file_list
      },
      changes: {
         non_contexted: true,
         regexp: /^%changelog/i,
         parse_func: :parse_changes
      },
      context: {
         non_contexted: true,
         regexp: /^%(?:(?:global|define)|((?!description|package|files)[^\s]+))\s+(?:([^\s]+)\s+([^\s].*)|(.*))/i,
         parse_func: :parse_context
      },
      comment: {
         non_contexted: true,
         parse_func: :parse_comment
      }
   }.to_os(hash: true)

   def source source_in
      if source_in.respond_to?(:readlines)
         source_in.rewind
         source_in.readlines
      else
         source_in.split("\n")
      end
   end

   def parse source_in, options = {}
      context = {}.to_os
      matched = {}.to_os
      match = nil
      state_in = {
         "context" => {
            "__options" => options.to_os,
            "__custom" => { 'gemname' => '%pkgname' }.to_os
         }
      }.to_os(hash: true)

      state = source(source_in).reduce(state_in) do |state, line|
         SCHEME.find do |key, rule|
            match = rule.is_a?(Regexp) && rule.match(line) ||
                    rule.is_a?(OpenStruct) && rule[:regexp] && rule[:regexp].match(line)

            if match
               if matched.name
                  if matched.name != key
   #               binding.pry if matched[:match][0] =~ /description/
                     store_value(state, matched[:match], matched[:name], matched[:flow], context)
                     matched = { name: key.to_s, flow: "", match: match }.to_os
                  end
               else
                  matched = { name: key.to_s, flow: "", match: match }.to_os
               end
            end
         end

         if matched.name
            if matched.flow
               matched.flow << line + "\n"
            else
               matched.flow = line + "\n"
            end
         else
            matched = { name: "comment", flow: line + "\n", match: [] }.to_os
         end

         state
      end

      store_value(state, matched.match, matched.name, matched.flow, context)

      #binding.pry
      state
   end

   def store_value opts, match, key, flow, context
      data = SCHEME[key]
      rule = data.is_a?(OpenStruct) && data.rule || data
      parse_func = data.is_a?(OpenStruct) && data.parse_func || :parse_default
      non_contexted = data.is_a?(OpenStruct) && data.non_contexted
      reflown = reeval(flow, opts)
      rematched = match.to_a.map { |x| x.is_a?(String) && reeval(x, opts) || x }
      value = method(parse_func)[rematched, reflown, opts, context]
      mode = data.is_a?(OpenStruct) && data.mode || :append
      copts = !non_contexted && context.name && opts.secondaries.find do |sec|
         sec.name == Baltix::Spec::Rpm::Name.parse(
            context.name,
            aliases: aliased_names(opts))
      end || opts
      #binding.pry if key =~ /summar/
      #binding.pry if context[:kind]
      if !non_contexted && context.kind && context.kind.to_s != copts["name"].kind
         copts["kname"] = Baltix::Spec::Rpm::Name.parse(copts["name"].alias_map[nil].first,kind: context.kind)

         #   Baltix::Spec::Rpm::Name.parse(copts["name"].alias_map[context.kind.to_s]&.first || copts["name"].original_fullname,
         #      kind: context.kind)
      end

      copts[key] =
      case copts[key]
      when NilClass
         value
      when Array
         copts[key] | [ value.is_a?(OpenStruct) && value || value ].flatten
      when OpenStruct
         copts[key].deep_merge(value, mode: mode)
      else
         value
      end

      #binding.pry if key =~ /summar/
      opts
   end

   def secondary_for_context opts, context
      opts.secondaries.find do |sec|
      #binding.pry
         sec.name == Baltix::Spec::Rpm::Name.parse(
            context.name,
            aliases: aliased_names(opts))
      end
   end

   def reeval flow, opts
      #binding.pry if flow =~ /%gemname/
      [opts.context.__options, opts.context.__macros, opts, opts.context.__custom].compact.reduce(flow) do |reflown_in, source|
         source.table.keys.sort_by {|x|x.size}.reverse.reduce(reflown_in) do |reflown, name|
            next reflown if /context|__macros|__options/ =~ name
            value = source[name]
            #binding.pry if flow =~ /%gemname/ && name =~ /%gemname/
            r = reflown.dup
            r.gsub!(/%({#{name}}|#{name})/, value.to_s) && value.is_a?(String) && /^%/ =~ value ? reeval(r, opts) : r
         end
      end || raise #flow
   end

   def parse_name match, *_
      Baltix::Spec::Rpm::Name.parse(match[1])
   end

   def parse_comment match, flow, *_
      flow
   end

   def parse_file match, *_
      { match[1] || "0" => match[2] }.to_os
   end

   def parse_file_list match, flow, opts, context
      kind = {
         lib: /ruby_gemspec|ruby_gemlibdir/,
         doc: /ruby_gemdocdir/,
         exec: /_bindir/,
      }.find { |(k, re)| re =~ flow }&.[](0)
      context.replace(parse_context_line(match[1], opts).merge(kind: kind))
      splitten_flow(flow)
   end

   def parse_changes _, flow, *_
      rows = flow.split("\n* ").map { |p| p.strip }.compact.map { |p| p.split("\n") }

      rows[1..-1].map do |row|
         /(?<date>^\w+\s+\w+\s+\w+\s+\w+)\s+(?<author>.*)\s*(?:<(?<email>.*)>)\s+(?:(?<epoch>[0-9]+):)?(?<version>[\w\.]+)(?:-(?<release>[\w\._]+))?$/ =~ row[0]

         {
            date: date,
            author: author.strip,
            email: email,
            version: Gem::Version.new(version),
            release: release,
            epoch: epoch,
            description: row[1..-1].join("\n")
         }.to_os
      end.reverse
   end

   def parse_dep match, *_
      deps = match[1].scan(/[^\s]+(?:\s+[<=>]+\s+[^\s]+)?/)
      deps.reject {|d| /^(gem|rubygem|ruby-gem)\(/ =~ d }
   end

   def parse_ignore match, *_
      match[2].split(/,/).map {|x| x =~ /^\/(.*)/ && /#{$1}/ || x }
   end

   def parse_default match, *_
      match[1]
   end

   def parse_plain_section _, flow, *_
      splitten_flow(flow)
   end

   # secondary without suffix by default has kind of lib
   def parse_secondary match, flow, opts, context
      context.replace(parse_context_line(match[1], opts))
      name = Baltix::Spec::Rpm::Name.parse(context.name, aliases: aliased_names(opts))

      [{ "name" => name, "version" => opts.version, "release" => opts.release, "summaries" => opts.summaries.dup }.to_os ]
   end

   def parse_description match, flow, opts, context
      context.replace(parse_context_line(match[1], opts))
      { context.cp || Baltix::I18n.default_locale => splitten_flow(flow) }.to_os
   end

   def parse_license match, *_
      match[1].split(/(?: or |\/)/).map(&:strip)
   end

   def parse_summary match, _, opts, *_
      opts.summary = match[2]
      { match[1] || Baltix::I18n.default_locale => match[2] }.to_os
   end

   def parse_context match, *_
      if match[1]
         {
            "__macros" => {
               match[1] => match[4]&.strip || [match[2], match[3]].compact.join(" ").strip
            }
         }.to_os(hash: true)
      elsif match[2]
         {
            "__macros" => {
               match[2] => match[5]&.strip || [match[3], match[4]].compact.join(" ").strip
            }
         }.to_os(hash: true)
      else
         { match[3] => match[4] }.to_os
      end
   end

   def parse_version match, *_
      Gem::Version.new(match[1])
   end

   def parse_packager match, *_
      OpenStruct.new(name: match[1]&.strip, email: match[2]&.strip)
   end

   def parse_context_line line, opts
      key = nil
      context = line.to_s.split(/\s+/).reduce({}.to_os) do |res, arg|
      #binding.pry
         case arg
         when '-l'
            key = :cp
         when '-n'
            key = :fullname
         else
            case key
            when :cp
               res.cp = arg
            when :fullname
               res.name = arg
            else
               res.name = "#{opts.name}-#{arg}"
            end
         end

         res
      end

      if context.name
         opts.secondaries ||= []
#         name = Baltix::Spec::Rpm::Name.parse(context[:name])
#      binding.pry
#         sel = opts["secondaries"].select { |sec| sec.name == name }

#            opts["secondaries"] << { "name" => name }.to_os if sel.blank?
      end
#      binding.pry

      context
   end

   def aliased_names opts
      opts.context.__options&.aliased_names
   end

   protected

   def splitten_flow flow
      (flow.split("\n")[1..-1] || []).join("\n")
   end

   class << self
      def match? source_in
         MATCHER =~ source_in
      end
   end
end
