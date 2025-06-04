require "erb"

require 'baltix/spec'
require 'baltix/i18n'

class Baltix::Spec::Rpm
   attr_reader :comment, :space, :host

   %w(Name Parser Secondary SpecCore).reduce({}) do |types, name|
     autoload(:"#{name}", File.dirname(__FILE__) + "/rpm/#{name.snakeize}")
   end

   OPTIONS = %w(source conflicts uri vcs maintainer
                source_files patches build_pre_requires context comment
                readme executables ignored_names main_source dependencies
                valid_sources available_gem_list rootdir aliased_names
                time_stamp devel_dep_setup use_gem_version_list use_gem_obsolete_list)

   HAS_PARTS = {
      lib: nil,
      exec: :has_executables?,
      doc: :has_docs?,
      devel: :has_devel?,
   }

   STATE_CHANGE_NAMES = %w(name version summaries licenses group uri vcs
      packager build_arch source_files build_pre_requires descriptions secondaries
      prep build install check file_list)

   CHANGES_MAJORITY = {
      fix: :minor,
      explicit_deps: :minor,
      rename: :major,
      upgrade: :version,
      new: :new,
   }

   STATE = {
      name: {
         seq: %w(of_options of_state of_source of_default >_name >_global_rename -_post_name),
         default: "",
      },
      pre_name: {
         seq: %w(of_options of_state of_default >_pre_name),
         default: "",
      },
      epoch: {
         seq: %w(of_options of_source of_state),
         default: nil,
      },
      version: {
         seq: %w(of_options of_source of_state of_default >_version_of_secondaries >_reversion >_version -_post_version),
         default: ->(this) { this.options.time_stamp || Time.now.strftime("%Y%m%d") },
      },
      release: {
         seq: %w(of_options of_state >_release),
         default: "alt1",
      },
      build_arch: {
         seq: %w(of_options of_state of_source),
         default: "noarch",
      },
      summaries: {
         seq: %w(of_options of_state of_source of_default >_summaries),
         default: ""
      },
      group: {
         seq: %w(of_options of_state of_source),
         default: ->(this) { Baltix::I18n.t("spec.rpm.#{this.kind}.group") },
      },
      requires: {
         seq: %w(of_options of_state of_default >_filter_out_obsolete >_requires_plain_only >_requires_ruby >_requires_rubygems |_host_require |_kind_deps >_render_bottom_dep),
         default: [],
      },
      conflicts: {
         seq: %w(of_options of_state of_default >_conflicts_plain_only |_conflicts_ruby |_kind_deps >_render_top_dep),
         default: [],
      },
      provides: {
         seq: %w(of_options of_state of_default >_provides |_find_provides |_lib_provide -_post_provides >_render_bottom_dep),
         default: [],
      },
      obsoletes: {
         seq: %w(of_options of_state of_default >_obsoletes >_find_obsoletes),
         default: [],
      },
      file_list: {
         seq: %w(of_options of_state of_source),
         default: "",
      },
      licenses: {
         seq: %w(of_options of_state >_licenses),
         default: [],
      },
      uri: {
         seq: %w(of_options of_state of_source),
         default: nil,
      },
      vcs: {
         seq: %w(of_options of_state of_source >_vcs),
         default: nil,
      },
      packager: {
         seq: %w(of_options of_state),
         default: ->(this) do
            OpenStruct.new(
               name: this.options.maintainer&.name || "Spec Author",
               email: this.options.maintainer&.email || "author@example.org"
            )
         end
      },
      maintainer: {
         seq: %w(of_options of_state),
         default: ->(this) do
            OpenStruct.new(
               name: this.options.maintainer&.name || "Spec Author",
               email: this.options.maintainer&.email || "author@example.org"
            )
         end
      },
      source_files: {
         seq: %w(of_options of_state of_default >_source_files),
         default: { "0": "%name-%version.tar" }.to_os,
      },
      patches: {
         seq: %w(of_options of_state),
         default: {}.to_os,
      },
      devel_dependencies: {
         seq: %w(of_options of_state of_default >_prepare_dependencies >_devel_dependencies >_fix_dependencies_groups >_replace_versioning_dependencies >_dependencies_sort),
         default: [],
      },
      binary_dependencies: {
         seq: %w(of_options of_state of_default >_prepare_dependencies >_binary_dependencies >_replace_versioning_dependencies >_dependencies_sort),
         default: [],
      },
      runtime_dependencies: {
         seq: %w(of_options of_state of_default >_prepare_dependencies >_runtime_dependencies >_replace_versioning_dependencies >_dependencies_sort),
         default: [],
      },
      build_dependencies: {
         seq: %w(of_options of_state of_default >_prepare_dependencies >_build_dependencies >_fix_dependencies_groups >_build_dependencies_filter >_replace_versioning_dependencies >_dependencies_sort),
         default: [],
      },
      check_dependencies: {
         seq: %w(of_options of_state of_default >_prepare_dependencies >_check_dependencies >_fix_dependencies_groups >_check_dependencies_filter >_replace_versioning_dependencies >_dependencies_sort),
         default: [],
      },
      build_requires: {
         seq: %w(of_options of_state of_default >_filter_out_build_auto_requires >_filter_out_obsolete |_build_requires),
         default: [],
      },
      check_requires: {
         seq: %w(of_options of_state of_default |_check_requires),
         default: [],
      },
      build_conflicts: {
         seq: %w(of_options of_state of_default |_build_conflicts),
         default: [],
      },
      check_conflicts: {
         seq: %w(of_options of_state of_default |_check_conflicts),
         default: [],
      },
      build_pre_requires: {
         seq: %w(of_options of_state of_default >_build_pre_requires),
         default: [ "rpm-build-ruby" ],
      },
      changes: {
         seq: %w(of_options of_state of_source of_default >_collect_changes >_changes),
         default: []
      },
      prep: {
         seq: %w(of_options of_state),
         default: "%setup",
      },
      build: {
         seq: %w(of_options of_state),
         default: "%ruby_build",
      },
      install: {
         seq: %w(of_options of_state),
         default: "%ruby_install",
      },
      check: {
         seq: %w(of_options of_state),
         default: "%ruby_test",
      },
      secondaries: {
         seq: %w(of_options of_state of_default >_secondaries),
         default: [],
      },
      context: {
         seq: %w(of_options of_state),
         default: {}.to_os,
      },
      comment: {
         seq: %w(of_options of_state),
         default: nil,
      },
      spec_template: {
         seq: %w(of_options of_state),
         default: ->(_) { IO.read(File.join(File.dirname(__FILE__), "rpm.erb")) },
      },
      compilables: {
         seq: %w(of_options of_state of_source),
         default: [],
      },
      descriptions: {
         seq: %w(of_options of_state of_source of_default >_proceed_description >_descriptions >_format_descriptions),
         default: {}.to_os
      },
      valid_sources: {
         seq: %w(of_state of_space of_default),
         default: []
      },
      readme: {
         seq: %w(of_options of_source >_readme of_state),
         default: nil,
      },
      executables: {
         seq: %w(of_options of_source of_state),
         default: [],
      },
      docs: {
         seq: %w(of_options >_docs of_state),
         default: nil,
      },
      all_docs: {
         seq: %w(of_options >_sub_docs of_state),
         default: nil,
      },
      devel: {
         seq: %w(of_options >_devel of_state),
         default: nil,
      },
      devel_requires: {
         seq: %w(of_options of_state >_devel_requires),
         default: nil,
      },
      devel_conflicts: {
         seq: %w(of_options of_state >_devel_conflicts),
         default: nil,
      },
      devel_sources: {
         seq: %w(of_options >_devel_sources of_state),
         default: [],
      },
      files: {
         seq: %w(of_options >_files of_state),
         default: []
      },
      allfiles: {
         seq: %w(of_options of_source of_state),
         default: []
      },
      dependencies: {
         seq: %w(of_options of_state of_source),
         default: []
      },
      development_dependencies: {
         seq: %w(of_options of_state of_source),
         default: []
      },
      ruby_alias_names: {
         seq: %w(of_options of_state >_ruby_alias_names >_ruby_alias_names_local),
         default: []
      },
      gem_versionings: {
         seq: %w(of_options of_state >_gem_versionings_with_use),
         default: []
      },
      ignored_names: {
         seq: %w(of_options |of_state),
         default: []
      },
      aliased_names: {
         seq: %w(of_options |of_state),
         default: []
      },
      available_gem_list: {
         seq: %w(of_options of_state >_available_gem_list),
         default: {}.to_os
      },
      versioned_gem_list: {
         seq: %w(of_options of_state >_versioned_gem_list),
         default: {}.to_os
      },
      available_gem_ranges: {
         seq: %w(of_options of_state >_available_gem_ranges),
         default: {}.to_os
      },
      use_gem_version_list: {
         seq: %w(of_options of_state >_use_gem_version_list),
         default: {}.to_os
      },
      use_gem_obsolete_list: {
         seq: %w(of_options of_state),
         default: {}.to_os
      },
      rootdir: {
         seq: %w(of_options of_state),
         default: nil
      },
      rake_build_tasks: {
         seq: %w(of_options of_source of_state of_default >_rake_build_tasks),
         default: ""
      }
   }.to_os(hash: true)

   include Baltix::Spec::Rpm::SpecCore
   include Baltix::I18n

   def render spec = nil
      b = binding

      ERB.new(spec || spec_template, trim_mode: "<>-", eoutvar: "@spec").result(b).strip
   end

   def macros name
      [ context.__macros[name] ].flatten(1).map { |x| "%#{name} #{x}" }.join("\n")
   end

   def is_same_source? source_in
      source_in && source == source_in
   end

   def kind
      @kind ||= source.is_a?(Baltix::Source::Gem) && :lib || :app
   end

   def state_kind
      @state_kind ||= pre_name&.kind || state['file_list'].blank? && default_state_kind
   end

   def default_state_kind
      "app"
   end

   def assign_space space
      @space = space

      #TODO clean variables

      space
   end

   def doc
      @doc ||= self
   end

   def names
      @names ||= [name.to_s] | secondaries.map {|sec| sec.name.to_s }.uniq
   end

   # +has_any_docs?+ returns true if self or child source has any doc
   #
   def has_any_docs?
      all_docs.any?
   end

   def pure_build_requires
      build_requires.select {|r| r !~ /^gem\(.*\)/ }
   end

   def pure_build_conflicts
      build_conflicts.select {|r| r !~ /^gem\(.*\)/ }
   end

   def gem_build_requires
      build_requires.select {|r| r =~ /^gem\(.*\)/ }
   end

   def gem_build_conflicts
      build_conflicts.select {|r| r =~ /^gem\(.*\)/ }
   end

   def has_gem_build_requires?
      gem_build_requires.any?
   end

   def has_gem_build_conflicts?
      gem_build_conflicts.any?
   end

   def source
      @source ||= space&.main_source || sources.find {|source_in| pre_name == source_in.name } || Baltix::Source::Fake.new({
         "name" => state.name&.fullname,
         "version" => state.version,
         "kind" => state.kind || state.name&.kind,
         "valid" => true})
   end

   # +sources+ infers sources from the space if any. filtered out by the ignore names filter 
   def sources
      @sources ||=
         space&.valid_sources.reject do |source_in|
            ignored_names.any? { |x| x === source_in.name }
         end
   end

   def valid_secondaries
     @valid_secondaries ||= secondaries.select do |s|
        s.source&.source_file
     end
   end

   def _sub_docs _in = []
      (of_source(:docs) || []) | secondaries.map {|s| s.docs }.flatten.compact
   end

   protected

   def ruby_build
      @ruby_build ||= variables.ruby_build&.split(/\s+/) || []
   end

   def _global_rename value_in
      # binding.pry
      case source
      when Baltix::Source::Gem
         value_in.class.parse(value_in, prefix: value_in.class.default_prefix)
      when Baltix::Source::Gemfile, Baltix::Source::Rakefile, Baltix::Source::Fake
         value_in.class.parse(value_in, prefix: nil, kind: "app", name: value_in.original_fullname)
      else
         value_in
      end
   end

   def _collect_changes value_in
      %i(name version provides).each {|x| send(x) }

      value_in
   end

   def _version_of_secondaries value_in
      vers = secondaries.group_by { |sec| sec.source&.version }.select {|k,_| k}.map {|v, arr| [v, arr.size] }.to_h

      if source.is_a?(Baltix::Source::Gemfile)
         vers.sort {|(_, sizes)| sizes }.last&.first
      end || value_in
   end

   def _versioned_gem_list value_in
      dep_list = dep_list_intersect(value_in.to_os, available_gem_ranges, gem_versionings)

      dep_list.select do |n, dep_in|
         source.all_dependencies.select { |dep| dep.name == n.to_s }.any? do |dep|
            dep_ver = combine_deps(dep, dep_in)
            dep_ver.requirement.requirements != dep.requirement.expand.requirements
         end
      end
   end

   def _gem_versionings_with_use value_in
      dep_list_merge(_gem_versionings(value_in), use_gem_version_list)
   end

   def autoaliases
      @autoaliases =
         secondaries.map do |sec|
            case sec.kind
            when :exec, :app
               sec.name.alias_for(sec.name.kind)
            when :lib
               sec.name.alias_for(sec.name.kind)
            end
         end.compact.flatten
   end

   def _ruby_alias_names value_in
      @ruby_alias_names ||= (value_in || []) | ruby_build.reduce([]) do |res, line|
         case line
         when /--use=(.*)/
            res << [ $1 ]
         when /--alias=(.*)/
            res.last << $1
         end

         res
      end.map do |aliases|
         aliases |
            [ aliased_names, [ autoaliases ]].map do |a|
               a.reject { |x| (x & aliases).blank? }
            end.flatten
      end
   end

   def _ruby_alias_names_local value_in
      return @ruby_alias_names_local if @ruby_alias_names_local

      names =
         if source.kind_of?(Baltix::Source::Gem)
            [source&.name, name&.name, name.alias_map["app"]].flatten
         else
            [source&.name, name&.fullname]
         end.compact.uniq

    #    binding.pry
      @ruby_alias_names_local = value_in | (names.size > 1 && [ names ] || [])
   end

   def _use_gem_version_list value_in
      value_in && value_in.map do |name, v|
         Gem::Dependency.new(name.to_s, Gem::Requirement.new(v))
      end
   end

   def _secondaries value_in
      names = value_in.map { |x| x.name }
      #context_in = { context: context }.to_os
      secondaries_in = of_state(:secondaries) || []

      # binding.pry
      to_ignore = ([source&.name] | ignored_names).flatten.compact
      secondaries = valid_sources.reject do |source_in|
         to_ignore.any? { |i| i === source_in.name }
      end.map do |source|
         state =
            secondaries_in.find do |osec|
               osec.name === source.name&&
                  %w(app lib).include?(osec.name.kind || osec.name.approximate_kind)
            end

         sec = Secondary.new(source: source,
                             doc: self,
                             state: state,
                             options: { name_prefix: name.prefix,
                                        gem_versionings: gem_versionings,
                                        available_gem_list: available_gem_list })

         secondary_parts_for(sec, source)
      end.concat(secondary_parts_for(self, source, )).flatten.uniq {|x| x.name.fullname }

      # binding.pry
      secondaries =
         names.reduce(secondaries) do |secs, an|
            next secs if secs.find { |sec| sec.name == an }
            sec = value_in.find { |sec| sec.name == an }
      # binding.pry if sec

            if sec.is_a?(Secondary)
               secs | [sec]
            elsif sec.is_a?(OpenStruct)
               #source = sources.find { |s| sec.name == s.name } || Baltix::Source::Fake.new
               source = Baltix::Source::Fake.new
               host = secs.find { |sec_in| sec_in.name.eql_by?(:name, sec.name) }

               secs | [Secondary.new(doc: self,
                             kind: sec.name.kind,#an.kind
                             doc: self,
                             host: host,
                             state: sec,
                             source: source,
                             options: { name: sec.name,
                                        gem_versionings: gem_versionings,
                                        available_gem_list: available_gem_list })]
            else
               secs
            end
         end

      # binding.pry
      secondaries =
         secondaries.select do |sec|
            sec.kind != :devel || options.devel_dep_setup != :skip
         end

      secondaries
   end

   def secondary_parts_for object, source
      context_in = { context: context }.to_os
      secondaries_in = of_state(:secondaries) || []

      HAS_PARTS.map do |(kind, func)|
         next object.is_a?(Secondary) && object || nil if !func

            state =
               secondaries_in.find do |osec|
                  kinds = [osec.name.kind || osec.name.approximate_kind, osec.kname&.kind || osec.kname&.approximate_kind].compact

                  if source.respond_to?(:spec) && source.spec.respond_to?(:executables)
                     (source.executables | [source.name]).any? {|s| osec.name === s }
                  else
                     osec.name === source.name
                  end && kinds.include?(kind.to_s)
               end

         if object.send(func) || state
            presec =
               Secondary.new(source: source,
                             doc: self,
                             kind: kind,
                             host: object,
                             state: state,
                             options: { name_prefix: kind != :exec && name.prefix || nil,
                                        gem_versionings: gem_versionings,
                                        available_gem_list: available_gem_list })

            unless presec.state
               state = secondaries_in.find { |osec| osec.name == presec.name }
               presec.state = state if state
            end

            presec
         end
      end.compact
   end

   def _build_dependencies value_in
      dep_hash = value_in.group_by {|x|x.name}.map {|n, x| [n, x.reduce {|res, y| res.merge(y) } ] }.to_h
 
      dep_hash.values | space.all_dependencies_for(kinds_in: :build)
   end

   def _build_dependencies_filter value_in
      #binding.pry
      value_in.select do |dep|
         Baltix::DSL.match_kind_dep(dep, :build)
      end
   end

   def _check_dependencies value_in
      dep_hash = value_in.group_by {|x|x.name}.map {|n, x| [n, x.reduce {|res, y| res.merge(y) } ] }.to_h

      dep_hash.values | space.all_dependencies_for(kinds_in: :test)
   end

   def _fix_dependencies_groups value_in
      state_build_requires_names = state.build_requires&.select {|x| x.is_a?(Gem::Dependency) }&.map {|x| x.name } || []

      value_in.map do |dep|
         if !options.high_default_dependencies_priority && state_build_requires_names.include?(dep.name)
            dep.groups -= Baltix::DSL.defined_groups_for(:test)

            dep
         else
            dep
            #Baltix::DSL::DEFAULT_GEM_GROUP.reduce(dep) do |d, (group, names)|
            #   names.find {|n| n === d.name } ? (d.groups = [group]; d) : d
            #end
         end
      end
   end

   def _check_dependencies_filter value_in
      #binding.pry
      value_in.reject do |dep|
         Baltix::DSL.match_kind_dep(dep, :build)
      end
   end

   def _filter_out_build_auto_requires value_in
      value_in.reject do |value|
         value.is_a?(String) and /^(#{Baltix::Spec::Rpm::Name::PREFICES.join('|')})[\-(]/ =~ value
      end
   end

   def _build_requires value_in
      render_deps(build_dependencies)
   end

   def _check_requires value_in
      render_deps(check_dependencies)
   end

   def _build_conflicts value_in
      render_deps(build_dependencies, :negate)
   end

   def _check_conflicts value_in
      render_deps(check_dependencies, :negate)
   end

   def _vcs value_in
      pre = URL_MATCHER.reduce(value_in) do |res, (rule, e)|
         vcs = res || uri
         vcs && (match = vcs.match(rule)) && e[match] || res
      end

      pre && "#{pre}#{/\.git/ !~ pre && ".git" || ""}".downcase || nil
   end

   def _source_files value_in
      source_files = value_in.dup
      defaults = of_default(:source_files)[:"0"]

      source_files[:"0"] = defaults if source_files[:"0"] != defaults

      source_files
   end

   def _build_pre_requires value_in
      build_pre_requires = value_in.dup || []
      stated_name = of_state(:name)

      if stated_name && stated_name.prefix != name.prefix
         default = of_default(:build_pre_requires)[0]

         build_pre_requires.unshift(default) unless build_pre_requires.include?(default)
      end

      build_pre_requires
   end

   def _licenses value_in
      list =
         sources.map do |source|
            source.licenses
         end.flatten.uniq.map do |l|
            Baltix::License.parse(l)
         end

      !list.blank? && list || value_in.blank? && ["Unlicense"] || value_in
   end

   def state_changed?
      @state_changed = STATE_CHANGE_NAMES.any? do |property|
         if property == "secondary"
            [ of_state(property), self.send(property) ].transpose.any? do |(first, second)|
               first.name != second.name
            end
         else
            of_state(property) != self.send(property)
         end
#
#         when String, Name, Gem::Version, NilClass,
#         binding.prya
#         when Array
#         binding.pry
#            of_state(property) == self.send(property)
#         when OpenStruct
#         binding.pry
#            of_state(property) == self.send(property)
#         else
#         binding.pry
#         end
#
#         true
      end
   end

         #aif change_list.any?
   def _changes value_in
      new_change =
         if change_list.any?
            previous_version = of_state(:version)
            version, release = evr_from_changes

            OpenStruct.new(
               date: Date.today.strftime("%a %b %d %Y"),
               author: options.maintainer&.name || packager.name,
               email: options.maintainer&.email || packager.email,
               epoch: epoch,
               version: version,
               release: release,
               description: descriptions_from_changes(binding))
         end

      value_in | [ new_change ].compact
   end

   def descriptions_from_changes b
      change_list.sort_by {|x| -CHANGES_MAJORITY.keys.index(x) }.map do |ch|
         Baltix::I18n.t("spec.rpm.change.#{ch}", binding: b)
      end.join("\n")
   end

   def evr_from_changes
      chgs = change_list.map {|c| CHANGES_MAJORITY[c] }.uniq

      if chgs.include?(:new)
         [self.version, of_state(:release) || of_options(:release) || "alt1"]
      elsif chgs.include?(:version)
         [self.version, of_options(:release) || "alt1"]
      elsif chgs.include?(:major)
         /alt(?<release_version>.*)/ =~ of_state(:release)
         release_major_bump = Gem::Version.new(release_version.split(/[\._]/).first).bump.to_s

         [self.version, "alt#{release_major_bump}"]
      else
         /alt(?<release_version>.*)/ =~ of_state(:release)
         parts = release_version.split(/[\._]/)
         release_minor_bump = Gem::Version.new(parts[1] || "0").bump.to_s

         [self.version, "alt#{parts[0]}.#{release_minor_bump}"]
      end
   end

   def _release value_in
      changes.last ? changes.last.release : nil
   end

   def _rake_build_tasks value_in
      /--pre=(?<list>[^\s]*)/ =~ %w(context __macros ruby_build).reduce(state) {|r, a| r&.[](a) }

      value_in.split(",") | (of_state(:ruby_on_build_rake_tasks) || list || "").split(",")
   end

   def initialize state: {}, options: {}, space: nil
      @state = state.to_os
      @options = options.to_os.merge(space.options)
      @space = space || raise
      @doc = self
   end

   class << self
      def match? source_in
         Parser.match?(source_in)
      end

      def parse source_in, options = {}.to_os, space = nil
         state = Parser.new.parse(source_in, options)
         space ||= options[:space]

         Baltix::Spec::Rpm.new(state: state, options: options, space: space)
      end

      def render space, spec_in = nil
         spec = space.spec || self.new(space: space)

         spec.render(spec_in)
      end
   end
end
