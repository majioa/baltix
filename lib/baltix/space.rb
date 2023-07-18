require 'rubygems'

require 'baltix/version'
require 'baltix/log'
require 'baltix/source'
require 'baltix/spec'
require 'baltix/cli'

class Baltix::Space
   include Baltix::Log

   class InvalidSpaceFileError < StandardError; end

   TYPES = {
      sources: Baltix::Source
   }

   STATES = {
      invalid: ->(_, source, _) { !source.valid? },
      disabled: ->(space, source, _) { space.is_disabled?(source) },
      duplicated: ->(_, _, dup) { dup },
   }

   TYPE_CHARS = {
      fake: '·',
      gem: '*',
      gemfile: '&',
      rakefile: '^',
   }

   STATUS_CHARS = {
      invalid: 'X',
      disabled: '-',
      duplicated: '=',
      valid: 'V',
   }


   Gem.load_yaml

   @@space = {}
   @@options = {}

   # +options+ property returns the hash of the loaded options if any
   #
   # options #=> {...}
   #
   attr_reader :options, :state

   # +name+ returns a default name of the space with a prefix if any. It returns name of a source when
   # its root is the same as the space's root, or returns name defined in the spec if any.
   # If no spec defined returns name of last folder in rootdir or "root" as a default main source name.
   #
   # space.name # => space-name
   #
   def name
      return @name if @name

      @name = spec&.name || main_source&.name
   end

   # +version+ returns a default version for the space. Returns version of a source when
   # its root is the same as the space's root, or returns version defined in the spec if any,
   # or returns default one.
   #
   # space.version # => 2.1.1
   #
   def version
      return @version if @version

      @version ||= main_source&.version || spec&.version
   end

   attr_writer :rootdir

   # +rootdir+ returns the root dir for the space got from the options,
   # defaulting to the current folder.
   #
   # rootdir #=> /root/dir/for/the/space
   #
   def rootdir
      @rootdir ||= read_attribute(:rootdir) || Dir.pwd
   end

   # +main_source+ selects main source from the list of sources when source root dir is the space's one and
   # source's name contains minimum name size among the matching sources
   #
   def main_source
      return @main_source if @main_source

      reals = valid_sources.select { |source| !source.is_a?(Baltix::Source::Fake) }
      if spec && !spec.state.blank?
         specen_source = reals.find { |real| spec.state["name"] === real.name }
      end

      root_source ||= valid_sources.sort {|x, y| x.name.size <=> y.name.size }.find { |source| source.rootdir == rootdir }
      @main_source =
         specen_source || root_source.is_a?(Baltix::Source::Fake) && reals.size == 1 && reals.first || root_source
   end

   def time_stamp
      Time.now.strftime("%Y%m%d")
   end

   # +changes+ returns a list of open-struct formatted changes in the space or
   # spec defined if any, otherwise returns blank array.
   #
   # space.changes # => []
   #
   def changes
      @changes ||= spec&.changes || main_source&.respond_to?(:changes) && main_source.changes || []
   end

   # +summaries+ returns an open-struct formatted summaries with locales as keys
   # in the space or spec defined if any, otherwise returns blank open struct.
   #
   # space.summaries # => #<OpenStruct en_US.UTF-8: ...>
   #
   def summaries
      return @summaries if @summaries

      if summaries = spec&.summaries || state.summaries
         summaries
      elsif summary = main_source&.summary
         { Baltix::I18n.default_locale => summary }.to_os
      end
   end

   # +licenses+ returns license list defined in all the valid sources found in the space.
   #
   # space.licenses => # ["MIT"]
   #
   def licenses
      return @licenses if @licenses

      licenses = valid_sources.map { |source| source.licenses rescue [] }.flatten.uniq

      @licenses = !licenses.blank? && licenses || spec&.licenses || []
   end

   # +dependencies+ returns all the valid source dependencies list as an array of Gem::Dependency
   # objects, otherwise returning blank array.
   def dependencies
      @dependencies ||= valid_sources.map do |source|
         source.respond_to?(:dependencies) && source.dependencies || []
      end.flatten.reject do |dep|
         match_platform?(dep) || sources.any? do |s|
            dep.name == s.name &&
            dep.requirement.satisfied_by?(Gem::Version.new(s.version))
         end
      end
   end

   def match_platform? dep
      if dep.respond_to?(:platforms)
         (dep.platforms & options.skip_platforms).any?
      end
   end

   def files
      @files ||= valid_sources.map { |s| s.files rescue [] }.flatten.uniq
   end

   def executables
      @executables ||= valid_sources.map { |s| s.executables rescue [] }.flatten.uniq
   end

   def docs
      @docs ||= valid_sources.map { |s| s.docs rescue [] }.flatten.uniq
   end

   def compilables
      @compilables ||= valid_sources.map { |s| s.extensions rescue [] }.flatten.uniq
   end

   # +sources+ returns all the sources in the space. It will load from the space sources,
   # or by default will search sources in the provided folder or the current one.
   #
   # space.sources => # [#<Baltix::Source:...>, #<...>]
   #
   def sources
      @sources ||= stat_sources.map { |x| x.first }
   end

   # +valid_sources+ returns all the valid sources based on the current source list.
   #
   # space.valid_sources => # [#<Baltix::Source:...>, #<...>]
   #
#   def valid_sources
#      @valid_sources ||= sources.select do |source|
#         source.valid? && is_regarded?(source)
#      end
#   end
   def valid_sources
      @valid_sources = stat_sources.map {|(source, status)| status == :valid && source || nil }.compact
   end

#   def is_regarded? source
#      regarded_names.any? {|i| i === source.name } ||
#         !ignored_names.any? {|i| i === source.name } &&
#         !ignored_path_tokens.any? {|t| /\/#{t}\// =~ source.source_file }
#   end

   def ignored_names
      @ignored_names ||= (read_attribute(:ignored_names) || [])
   end

   def regarded_names
      @regarded_names ||= read_attribute(:regarded_names) || []
   end

   def ignored_path_tokens
      @ignored_path_tokens ||= (read_attribute(:ignored_path_tokens) || [])
   end

   def spec_type
      @spec_type ||= read_attribute(:spec_type) || spec && spec.class.to_s.split("::").last.downcase
   end

   def read_attribute attr
      options.send(attr) || state.send(attr)
   end

   def options_for type
      @@options[type] = type::OPTIONS.map do |option|
         value = self.options[option] || self.respond_to?(option) && self.send(option) || nil

         [ option, value ]
      end.compact.to_os
   end

   # +spec+ property returns the hash of the loaded spec if any, it can be freely
   # reassigned.
   #
   # spec #=> {...}
   #
   def spec
      @spec ||= gen_spec
   end

   def spec= value
      gen_spec(value)
   end

   def is_disabled? source
      options.ignored_path_tokens.any? { |t| /\/#{t}\// =~ source.source_file } ||
         options.regarded_names.all? { |i| !i.match?(source.name) } &&
         options.ignored_names.any? { |i| i === source.name }
   end

   protected

   def gen_spec spec_in = nil
      spec_pre = spec_in || state.spec

      @spec =
         if spec_pre.is_a?(Baltix::Spec::Rpm)
            spec_pre
         elsif spec_pre.is_a?(String)
            self.class.load(spec_pre)
         elsif options&.spec_file
            Baltix::Spec.load_from(source: IO.read(options.spec_file), options: options, space: self)
         elsif @spec_type || options&.spec_type
            Baltix::Spec.find(@spec_type || options.spec_type).new(options: options, space: self)
         end

      @spec.assign_space(self) if @spec

      @spec
   end

   def initialize state_in = {}, options = {}
      @options = Baltix::CLI::DEFAULT_OPTIONS.merge(options || {})
      @state = (state_in || {}).to_os

      baltix_log
   end

   # init log
   def baltix_log
      ios = DEFAULT_IO_NAMES.merge(%i(error warn info debug).map {|k| [k, options["#{k}_io"]]}.to_h)
      Baltix::Log.setup(options.log_level.to_sym, ios)
   end

   def show_tree
      info("Sources:")
      stat_source_tree.each do |(path_in, stated_sources)|
         stated_sources.each do |(source, status)|
            path = source.source_path_from(rootdir) if source.source_file
            stat = [STATUS_CHARS[status], TYPE_CHARS[source.type.to_sym]].join(" ")
            namever = [source.name, source.version].compact.join(":")
            info_in = "#{stat}#{namever} [#{path}]"

            info(info_in)
         end
      end
   end

   # returns all the sources with their statuses, and sorted by a its rootdir value
   #
   def stat_sources &block
      return @stat_sources if @stat_sources

      @stat_sources =
         read_attribute(:stat_sources) || Baltix::Source.search_in(rootdir, options).group_by do |x|
            [x.name, x.version].compact.join(":")
         end.map do |(full_name, v)|
            sorten =
               v.sort do |x,y|
                  c0 = ::Baltix::Source.loaders.index(x.loader) <=> ::Baltix::Source.loaders.index(y.loader)
                  c1 = c0 == 0 && x.name <=> y.name || c0
                  c2 = c1 == 0 && y.version <=> x.version || c1
                  c3 = c2 == 0 && y.platform <=> x.platform || c2
                  c4 = c3 == 0 && y.source_names.grep(/gemspec/).count <=> x.source_names.grep(/gemspec/).count

                  c2 == 0 && c3 == 0 && c4 == 0 && x.rootdir.size <=> y.rootdir.size || c4 != 0 && c4 || c3 != 0 && c3 || c2
               end.reduce([[], 0]) do |(res, index), source|
                  dup = source.valid? && index > 0
                  dup_index = source.valid? && index + 1 || index

                  [res | [[source, source_status(source, dup)]], dup_index]
               end.first

            sorten[1..-1].each { |x| sorten.first.first.alias_to(x.first) }

            sorten
         end.flatten(1).sort_by {|(x, _)| x.rootdir.size }.each do |(source, status)|
            block[source, status] if block_given?
         end

      show_tree

      @stat_sources
   end

   # returns source tree, and sorted, and then grouped by a its rootdir value
   #
   def stat_source_tree
      @stat_source_tree ||=
         stat_sources.group_by {|(x, _)| x.rootdir }.map do |(path, sources)|
            [File.join('.', path[rootdir.size..-1] || ''), sources]
         end.to_h
   end

   # returns status for the source for the project
   #
   def source_status source, dup
      %i(valid duplicated disabled invalid).reduce() do |res, status|
         STATES[status][self, source, dup] && status || res
      end
   end

   def context
      @context ||= options[:context] || spec&.context || {}
   end

   def method_missing method, *args
      value =
         instance_variable_get(:"@#{method}") ||
         (spec.send(method) rescue nil) ||
         options&.[](method) ||
         spec&.options&.[](method.to_s) ||
         state[method]

      instance_variable_set(:"@#{method}", value || super)

      value
   end

   class << self
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

      def load_from! state: Dir[".space"].first, options: {}
#         system_path_check # TODO required to generate spec rubocop

         state_tmp =
            case state
            when IO, StringIO
               load(state.readlines.join(""))
            when String
               raise InvalidSpaceFileError.new(state: state) if !File.file?(state)

               load(IO.read(state))
            when NilClass
            else
               raise InvalidSpaceFileError
            end.to_os

         @@space[state_tmp.name] = self.new(state_tmp, options)
      end

      def load_from state: Dir[".space"].first, options: {}
         load_from!(state: state, options: options)
      rescue InvalidSpaceFileError
         @@space[nil] = new(nil, options)
      end
   end
end

require 'baltix/space/spec'
