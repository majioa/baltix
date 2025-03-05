require "json"

module Baltix::Spec::Rpm::SpecCore
   URL_MATCHER = {
      /(?<proto>https?:\/\/)?(?<user>[^\.]+).github.io\/(?<page>[^\/#]+)/ => ->(m) do
         "https://github.com/#{m["user"]}/#{m["page"]}.git"
      end,
      /(?<proto>https?:\/\/)?bogomips.org\/(?<page>[^\/#]+)/ => ->(m) do
         "https://bogomips.org/#{m["page"]}.git"
      end,
      /(?<proto>https?:\/\/)?github.com\/(?<user>[^\/]+)\/(?<page>[^\/\.#]+)/ => ->(m) do
         "https://github.com/#{m["user"]}/#{m["page"]}.git"
      end
   }

   def of_source name
      source.send(name) || nil
   rescue NameError
      nil
   end

   def of_state name
      state[name.to_s] || state[name.to_sym]
   end

   def of_options name
      options[name]
   end

   def of_space name
      space.respond_to?(name) ? space.send(name) : nil
   end

   def of_default name
      default = self.class::STATE[name][:default]

      default.is_a?(Proc) ? default[self] : default
   end

   def [] name
      instance_variable_get(:"@#{name}")
   end

   def []= name, value
      instance_variable_set(:"@#{name}", value)
   end

   def read_attribute name, seq = nil
      method = :copy
      aa = (seq || self.class::STATE[name][:seq]).reduce(nil) do |value_in, func|
       # binding.pry if name == :context
         /(?<method>[\-|>])*(?<mname>.*)/ =~ func

         value =
         if mname[0] == "_"
            if method(mname).arity == 0
               send(mname)
            else
               send(mname, value_in)
            end
         else
            send(mname, name)
         end

         case method
         when "|"
            [value_in].compact.flatten(1) | [value].compact.flatten(1)
         when "-"
            value_in
         when ">"
            value
         else #||
            value_in || value
         end
      end
      # binding.pry if name == :context
      aa
   end

   def options= options
      @options = options.to_os
   end

   def options
      @options ||= {}.to_os
   end

   def state
      @state ||= {}.to_os
   end

   def state= value
      if value.name
         @name = name.merge(value.name)
      end

      @state = value.to_os
   end

   def evr
      "#{epoch ? "#{epoch}:" : ""}#{version}-#{release}"
   end

   def summary
      summaries[Baltix::I18n.default_locale]
   end

   # +executable_name+ returns a name of the executable package, based on
   # the all the sources executables.
   #
   # spec.executable_name # => foo
   #
   def executable_name
      # TODO make smart selection of executable name
      @executable_name =
         if executables.size > 1
            max = executables.map { |x| x.size }.max
            exec_map = executables.map {|exec| (exec + " " * (max - exec.size)).unpack("U*") }
            filter = [45, 46, 95]

            exec_map.transpose.reverse.reduce([]) do |r, chars|
               if (chars | filter).size == chars.size || ([ chars.first ] | chars).size == 1
                  r.concat([ chars.first ])
               else
                  []
               end
            end.reverse.pack("U*").sub(/[-_\.]+$/, '')
         else
            executables.first&.gsub(/[_\.]/, '-') || ""
         end
   end

   def prefix
      name.class.default_prefix
   end

   protected

   def change_list
      @change_list ||= []
   end

   def change key
      change_list << key
   end

   def _name value_in
      (name, aliases, kind, su) =
         if is_exec?
            if doc.space.options.autorender_name && doc.source.is_a?(Baltix::Source::Gem)
               [ source.name, executables, self.kind ]
            else
               if state.name
                  [ state.name.to_s, executables, self.kind ]
               elsif executable_name.size >= 3
                  [ executable_name, executables, self.kind ]
               else
                  [ value_in, executables, self.kind ]
               end
            end
         elsif value_in.is_a?(Baltix::Spec::Rpm::Name)
            if source.is_a?(Baltix::Source::Gem)
               [ source.name, value_in.aliases, value_in.kind, value_in.support_name ]
            else
               if value_in.alias_map[self.kind.to_s]
                   [ value_in.alias_map[self.kind.to_s].first, [], value_in.kind, value_in.support_name ]
               else
                  [ value_in.name, value_in.aliases, value_in.kind, value_in.support_name ]
               end
            end
         else
            [ value_in, [], self.kind ]
         end

      Baltix::Spec::Rpm::Name.parse(name, kind: kind, prefix: options[:name_prefix], aliases: aliases, support_name: su)
   end

   def _post_name value_in
      state_name = of_state(:name)&.alias_map&.[](nil)&.first

      change(:rename) if state_name && of_state(:name) != value_in
      #change(:rename) if state_name && value_in != state_name

      value_in
   end

   def _post_version value_in
      case of_state(:version)
      when value_in
      when nil
         change(:new)
      else
         change(:upgrade)
      end

      value_in
   end

   def _local_rename value_in
#      if name.support_name.blank? # || name.support_name == name
#         if is_spec?
 
      # setup support name if any host
      value_in.support_name = host.name if host

      if host&.source&.kind_of?(Baltix::Source::Gem) && !is_exec?
         value_in.class.parse(value_in, prefix: value_in.class.default_prefix, support_name: value_in.support_name)
      elsif host && (host.source.kind_of?(Baltix::Source::Gemfile) || host.source.kind_of?(Baltix::Source::Rakefile))
         value_in.class.parse(value_in, support_name: value_in.support_name, name: value_in.support_name.original_fullname)
      else
         value_in
      end
   end

   # returns list of depencecies and devel sources without dep to itself
   def _devel _in = nil
      dependencies.reject { |x| x.name === source.name } | devel_sources
   end

   def _devel_sources _in = nil
      files.grep(/.*\.h(pp)?$/)
   end

   def _docs _in = nil
      of_source(:docs) || of_default(:docs)
   end

   def _summaries value_in
      source_name = source&.name
      summaries_in = @host && host.summaries || of_source(:summaries) || {}.to_os

      Baltix::I18n.locales.map do |locale_in|
         locale = locale_in.blank? && Baltix::I18n.default_locale || locale_in
         summary_pre = !%i(lib app).include?(self.kind) && summaries_in[locale_in] || value_in[locale] || value_in[locale_in] || nil
         summary = summary_pre&.match("(.*?)[\-\.,_\s]*?$")&.[](1)
         default = Baltix::I18n.t(:"spec.rpm.#{self.kind}.summary", locale: locale, binding: binding)

      #binding.pry
         if source.is_a?(Baltix::Source::Gem) or source.is_a?(Baltix::Source::Gemfile)
            [ locale_in, default ]
         else
            [ locale_in, summary ]
         end
      end.to_os.compact
   end

   def _devel_requires value_in
      value_tmp = value_in || source&.dependencies(:development) || []
      deps_versioned = replace_versioning(value_tmp)

      render_deps(append_versioning(deps_versioned))
   end

   def _devel_conflicts value_in
      value_tmp = value_in || source&.dependencies(:development) || []
      deps_versioned = replace_versioning(value_tmp)

      render_deps(append_versioning(deps_versioned), :negate)
   end

   def _files _in
      source&.files || []
   rescue
      []
   end

   def _proceed_description value_in
      value_in.map { |_locale, desc| desc.is_a?(Array) ? desc.join("\n") : desc }
   end

   def _descriptions value_in
      source_name = of_source(:name)
      summary = of_source(:summary)&.match("(.*?)[\.,-_\s]+$")&.[](1) # NOTE required for eval
      summaries_in = @host && summaries || { Baltix::I18n.default_locale => summary }
      descriptions_in = @host && host.descriptions || of_source(:descriptions) || of_source(:summaries) || {}.to_os

      Baltix::I18n.locales.map do |locale|
         sum = Baltix::I18n.t(:"spec.rpm.#{self.kind}.description", locale: locale, binding: binding)

         [ locale, sum ]
      end.to_os.map do |locale_in, summary_in|
         if locale_in.to_s == Baltix::I18n.default_locale
            if (source.is_a?(Baltix::Source::Gem) || source.is_a?(Baltix::Source::Gemfile)) && !%i(lib app).include?(self.kind)
               summary_in = summaries_in[locale_in]
               first = summary_in && (summary_in + ".")
               rest_in = descriptions_in[locale_in]
               /(?<re>.*)\.$/ =~ rest_in
               rest = first&.include?(re || rest_in || "") ? nil : rest_in
               [ first, rest ].compact.join("\n\n")
            else
               value_in[locale_in] || descriptions_in[locale_in]
            end
         else
            summary_in = summaries_in[locale_in]
            if source.is_a?(Baltix::Source::Gem) or source.is_a?(Baltix::Source::Gemfile)
               /(?<s>.+)\.?$/ =~ summary_in && s && "#{s}." || value_in[locale_in]
            else
               value_in[locale_in]
            end
         end
      end.compact
   end

   def _format_descriptions value_in
      value_in.map do |name, desc|
         tdesc = desc.gsub(/\n{2,}/, "\x1F\x1F").gsub(/\n([\*\-])/, "\x1F\\1").gsub(/\n/, "\s")
         new_desc =
            tdesc.split(/ +/).reduce([]) do |res, token|
               line = res.last
               uptoken = token.gsub(/(\n[^\-\*])/, "\n\\1").strip
               temp = [ line, uptoken ].reject { |x| x.blank? }.join(" ")

               if temp.size > 80 || !line
                  res << uptoken
               else
                  line.replace(temp)
               end

               postline = res.last.split(/\x1F/, -1)
               if postline.size > 1
                  res.last.replace(postline[0].strip)
                  res.concat(postline[1..-1].map(&:strip))
               end

               res
            end.join("\n")

         new_desc
      end
   end

   def _reversion value_in
      # TODO move reversion to space/sources
      # here is a workaround only
      # reversion to support newer ones
      reversion = gem_versionings.select {|n,v| name.eql?(n, true) }.to_h.values.first

      reversion || value_in
   end

   def _version value_in
      v =
         case value_in
         when Gem::Version
            value_in
         when Gem::Dependency
            value_in.requirement.requirements.first.last
         when Array
            Gem::Version.new(value_in.first.to_s)
         else
            Gem::Version.new(value_in.to_s)
         end

      if name.support_name.blank? # || name.support_name == name
         if is_dochost?
            (count, (version, sources_tmp)) =
               sources.group_by do |s|
                  s.version ? Gem::Version.new(s.version) : v
               end.map do |(x, y)|
                  [y.count, [x, y]]
               end.sort do |(x1, (v1, _)), (x2, (v2, _))|
                  s = x1 <=> x2

                  s == 0 ? v1 <=> v2 : s
               end.last

            v
         elsif source.respond_to?(:spec)
            source.spec.version
         elsif doc
            doc.version # TODO как отличить?
         end
      elsif host
         host.version
      else
         v
      end
   end

   def is_dochost?
      self.respond_to?(:space)
   end

   def is_host?
      !self.respond_to?(:host)
   end

   def _readme _in
      files.grep(/^[^\/]*(#{Baltix::Source::Base::DEFAULT_FILES.join("|")})/i).group_by do |x|
         File.basename(x)
      end.map do |(name, a)|
         a.first
      end.join(" ")
   end

   def _requires_plain_only value_in
      @requires_plain_only ||= value_in&.reject {|dep| dep.is_a?(Gem::Dependency) }
   end

   def _conflicts_plain_only value_in
      @conflicts_plain_only ||= value_in&.reject {|dep| dep.is_a?(Gem::Dependency) }
   end

   def _pre_name value_in
      return value_in if value_in.is_a?(Baltix::Spec::Rpm::Name)

      name = @name ||
         of_options(:name) ||
         of_state(:name) ||
         rootdir && rootdir.split("/").last ||
         value_in

      if name.is_a?(Baltix::Spec::Rpm::Name)
         name
      else
         Baltix::Spec::Rpm::Name.parse(name, prefix: options[:name_prefix])
      end
   end

   def _requires_ruby value_in
      value_in |
         case self.kind
         when :lib, :app
            reqs = source.dsl.required_rubies

            if !reqs.blank? && reqs.values.last.requirements.first.last.to_s != "0"
               [reqs]
            else
               []
            end
         else
            []
         end
   end

   def _conflicts_ruby value_in
         case self.kind
         when :lib, :app
            reqs = source.dsl.required_rubies

            if !reqs.blank? && reqs.values.last.requirements.first.last.to_s != "0"
               [reqs]
            else
               []
            end
         else
            []
         end
   end

   def _requires_rubygems value_in
      req_rgems =
         if %i(lib app).include?(kind) && source.dsl.required_rubygems.requirements.last.last.version.to_i > 0
            ["rubygems #{source.dsl.required_rubygems}"]
         end || []

      value_in | req_rgems
   end

   def _host_require value_in
      unless %i(lib app).include?(self.kind)
         [ doc.is_app? ? "#{doc.name} = #{doc.evr}" : provide_dep ].compact
      end
   end

   def _render_bottom_dep value_in
      render_deps(value_in)
   end

   def _kind_deps
      case self.kind
      when :app
         doc.space.dependencies_for(kinds_in: :runtime)
      when :lib
         runtime_dependencies
      when :devel
         if doc.is_app?
            doc.space.dependencies_for(kinds_in: :devel)
         else
            devel_dependencies
         end
      when :exec
         binary_dependencies
      else
         []
      end
   end

   def _render_top_dep value_in
      render_deps(value_in, :negate)
   end

   def _prepare_dependencies value_in
      value_in.map do |dep|
         if m = dep.match(/gem\((.*)\) ([>=<]+) ([\w\d\.\-]+)/)
            Gem::Dependency.new(m[1], Gem::Requirement.new(["#{m[2]} #{m[3]}"]), :runtime)
         else
            dep
         end
      end.compact
   end

   def _dependencies_sort value_in
      value_in.sort
   end

   def _replace_versioning_dependencies value_in
      provide_names = doc.secondaries.filter_map { |x| x.source&.provide&.name }.uniq

      replace_versioning(value_in).reject do |dep|
         if dep.is_a?(Gem::Dependency)
            dep.type == :development && options.devel_dep_setup == :skip || provide_names.include?(dep.name)
         end
      end
   end

#   def _append_versioning_dependencies value_in
#      append_versioning(value_in).reject do |n_in|
#         n = n_in.is_a?(Gem::Dependency) && n_in.name || n_in
#
#         name.eql?(n, true)
#      end
#   end

   def _runtime_dependencies value_in
      dep_hash = value_in.group_by {|x|x.name}.map {|n, x| [n, x.reduce {|res, y| res.merge(y) } ] }.to_h

      source.dsl.all_dependencies_for(kinds_in: :runtime).reduce(dep_hash.dup) do |r, x|
         r[x.name] = r[x.name] ? r[x.name].merge(x) : x

         r
      end.values
   end

   def _devel_dependencies value_in
      dep_hash = value_in.group_by {|x|x.name}.map {|n, x| [n, x.reduce {|res, y| res.merge(y) } ] }.to_h

      source.dsl.all_dependencies_for(kinds_in: :devel, kinds_out: :runtime).reduce(dep_hash.dup) do |r, x|
         r[x.name] = r[x.name] ? r[x.name].merge(x) : x

         r
      end.values
   end

   def _binary_dependencies value_in
      dep_hash = value_in.group_by {|x|x.name}.map {|n, x| [n, x.reduce {|res, y| res.merge(y) } ] }.to_h

      source.dsl.all_dependencies_for(kinds_in: :binary).reduce(dep_hash.dup) do |r, x|
         r[x.name] = r[x.name] ? r[x.name].merge(x) : x

         r
      end.values
   end

   # +replace_versioning+ replaces version of the +external+ libraties to align the any requires.
   # It is not affects to an in-sourced gem/lib versions
   def replace_versioning deps_in
      versioning_list = available_gem_ranges # NOTE removed merge with gem_versionings
#      versioning_list = available_gem_ranges.merge(gem_versionings)

      deps_in.map do |dep_in|
         if dep_in.is_a?(Gem::Dependency) && provide_dep&.name != dep_in.name
            dep = versioning_list[dep_in.name]

            if dep
               combine_deps(dep_in, dep)
            else
               dep_in
            end
         else
            dep_in
         end
      end
   end

   # +combine_deps+ method combines dependenies' requirements passed with arguments +base_dep+, and +dep+ base on
   # the operators in +base_dep+
   # Example:
   #    combine_deps(base_dep, dep)
   #
   def combine_deps base_dep, dep
      dep_ver = Gem::Dependency.new(base_dep.name, base_dep.requirement | dep.requirement)
      ops = base_dep.requirement.requirements.map {|x| x.first }.join(" ").gsub(/\A(~>|=)\z/, ">= < =").split(" ").uniq
      reqs = dep_ver.requirement.requirements.select {|x| ops.include?(x[0]) }

      dep_ver.requirement.requirements.replace(reqs)

      dep_ver
   end

   def append_versioning deps_in
      gem_versionings.reduce(deps_in) do |deps, name, dep|
         index = deps.index { |dep_in| dep_in.is_a?(Gem::Dependency) && dep_in.name == name.to_s }

         #binding.pry
         index && deps || deps | [ dep ]
      end
   end

   def variables
      @variables ||= context.__macros || {}.to_os
   end

   def render_deps deps_in, mode = :debound
      func = mode == :debound ? :lower_to_rpm : :upper_negate_to_rpm

      deps_in.reduce([]) do |deps, dep|
         deps |
            if dep.is_a?(Gem::Dependency)
               deph = Baltix::Deps.send(func, dep.requirement)

               deph.blank? ? [] : ["#{prefix}(#{dep.name}) #{deph.first} #{deph.last}"]
            elsif dep.is_a?(Hash)
               dep.map do |name, req|
                  deph = Baltix::Deps.send(func, req)

                  deph.blank? ? nil : "#{name} #{deph.first} #{deph.last}"
               end.compact
            else
               [dep]
            end
      end
   end

   def provide_dep
      return @provide_dep if @provide_dep

      name_tmp = source ? Baltix::Spec::Rpm::Name.parse(source.provide.name) : name
      provide_dep_pre = gem_versionings.select {|n,v| name_tmp.eql?(n, true) }.to_h.values.first || source&.provide || space.name

      @provide_dep = Gem::Dependency.new(provide_dep_pre.name, version)
   end

   def _provides value_in
      value_in.reduce([]) do |res, o|
         n = o.is_a?(Gem::Dependency) ? o.name : o

         names.include?(n) ? res : n =~ /^[^\s]+$/ ? res | [n + " = %EVR"] : res | [o]
      end.compact
   end

   def _post_provides value_in
      change(:explicit_deps) if value_in.present? && !state.provides
   end

   def _lib_provide
      render_deps([provide_dep].compact) if self.kind == :lib
   end

   def _find_provides
      state.name && state.name.original_fullname != name.fullname ? [state.name.original_fullname + " = %EVR"] : []
   end

   def _obsoletes value_in
      obsoletes =
         value_in.reduce([]) do |res, o|
            names.include?(o) ? res : o =~ /^[^\s]+$/ ? res | [o + " < %EVR"] : res | [o]
         end.compact
   end

   def _find_obsoletes value_in
      obsolete = state.name && state.name.original_fullname != name.fullname ? [state.name.original_fullname + " < %EVR"] : []

      value_in | obsolete
   end

   def _available_gem_list value_in
      value_in || options.available_gem_list
   end

   def _available_gem_ranges value_in
      available_gem_list.reduce({}.to_os) do |res, name, version_in|
         low = [ version_in ].flatten.map {|v| Gem::Version.new(v) }.min
         bottom = [ version_in ].flatten.map {|v| Gem::Version.new(v.to_s.split(".")[0..1].join(".")).bump }.max
         reqs = [ ">= #{low}", "< #{bottom}" ]

         res[name] = Gem::Dependency.new(name.to_s, Gem::Requirement.new(reqs))

         res
      end
   end

   def _filter_out_obsolete value_in
      value_in.reject do |value|
        value.is_a?(Gem::Dependency) || !use_gem_obsolete_list.[](value.match(/^(?<name>[^\s]+)/)[:name]).nil?
      end
   end

   def dep_list_merge first_in, second_in
      first = first_in || {}.to_os
      second = second_in || {}.to_os

      first.reduce(second.dup) do |r, name, req|
         if r[name]
            r[name] = r[name].merge(req)

            r
         else
            r.merge({ name => req }.to_os)
         end
      end
   end

   def dep_list_intersect *lists_in
      lists = lists_in.map {|list| list.to_os }

      lists.reduce do |r_list, list|
         list.reduce(r_list) do |r, name, req|
            if r[name]
               r[name] = Gem::Dependency.new("rake", req.requirement | r[name].requirement)

               r
            else
               r.merge({ name => req }.to_os)
            end
         end
      end
   end

   def _gem_versionings value_in
      pre_vers =
      [ variables.gem_replace_version ].flatten.compact.reduce({}.to_os) do |res, gemver|
         /^(?<name>[^\s]+)(?:\s(?<rel>[<=>~]+)\s(?<version>[^\s]+))?/ =~ gemver

         if res[name]
            res[name].requirement.requirements << [rel, Gem::Version.new(version)]
         else
            res[name] = Gem::Dependency.new(name, Gem::Requirement.new(["#{rel} #{version}"]))
         end

         res
      end

      dep_list_merge(value_in, pre_vers)
   end

   class << self
      def included obj
         obj::STATE.each do |name, opts|
            obj.define_method(name) { self[name] ||= read_attribute(name, opts[:seq]) || of_default(name) }
            #obj.define_method("_#{name}") { of_state[name] }
            obj.define_method("has_#{name}?") do
               options["#{name}_dep_setup"] != :skip && !read_attribute(name, opts["seq"]).blank?
            end
         end

         %w(lib exec doc devel app).each do |name|
            obj.define_method("is_#{name}?") { self.kind.to_s == name }
         end
      end
   end
end
