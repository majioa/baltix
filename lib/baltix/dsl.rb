require 'bundler'
require 'fileutils'
require 'tempfile'

require 'baltix'

# DSL service for baltix.
class Baltix::DSL
   # group to kinds mapping
   GROUP_MAPPING = {
      default: [:devel, :test, :runtime],
      integration: [:build, :devel],
      development: [:build, :devel],
      test: [:test, :devel],
      debug: :devel,
      runtime: [:runtime, :test],
      production: [:binary, :runtime],
      true => [:runtime, :binary]
   }.reduce(Hash.new([:devel])) {|r,(k,v)| r.merge(k => v) }

   PLATFORMS = {
      ruby: true,
      jruby: false
   }

   DEFAULT_GEM_GROUP = {
      :test => [
         /^minitest/, /cucumber/, /^rspec/, /^test-unit/, "test-kitchen", "rack-test", "multi_test", /^codeclimate.*test/,
         /^guard/, "sunspot_test", /^parallel_/, "buildkite-test_collector", "trailblazer-test", /^ae_/,
         "fastlane-plugin-test_center", "opentelemetry-test-helpers", "gitlab_quality-test_tooling", /^treye-.*(test|cucumber)/,
         "puppet-catalog-test", "testdata", "testrbl", /selenium/, "testcentricity_web", /^capybara/, "appium_lib",
         "awetestlib", /^simplecov/, "busser", "aruba", /rubocop/, "appraisal", /inspec/, "vcr", "gitlab-qa",
         "turn", "m", /^celluloid/, /faker/, /^danger/, /shoulda/, "crystalball", /^rcov/, "action-cable-testing",
         "email_spec", /^beaker/, "knapsack", "mail_view", /benchmark/, "approvals", "fakefs", "fivemat", "solano",
         "equivalent-xml", "generator_spec", "bourne", "optimizely-sdk", "puppetlabs_spec_helper", "xctest_list",
         "page-object", "slather", "split", "pusher-fake", "webrat", "puffing-billy", /mock/, "derailed_benchmarks", /kitchen/,
         /^database_cleaner/, "filelock", "parallelized_specs", "luffa", "stub_env", /^teaspoon/, "assert", "capistrano-spec",
         "flores", "ci_reporter", "testrail-ruby", "serverspec", "ci-queue", "cranky", "ladle", "gimme", "ruby-jmeter", "riot",
         /^calabash/, "resque_unit", /testing/, "accept_values_for", "temping", /^sauce/, "konacha", "watchr", "fabrication",
         "fantaskspec", "flights_gui_tests", "cuke_modeler", "axe-matchers", /^autotest/, /^stub/, "scan", "rr", "pwn",
         "linecook-gem", "robottelo_reporter", "unobtainium", "cornucopia", /rails.*test/, "its", "pdqtest",
         "webspicy", "expectations", /factory.*bot/, "fake_sqs", "evergreen", "filesystem", "sniff", "html-proofer", "bluff",
         "bogus", "pact-messages", "sapphire", /jasmine/, "culerity", "fauxhai", /^rufus/, "cobratest", "cypress-rails", "mirage"],
      :development => [/^bundle/, "native-package-installer", "pkg-config", "racc", /^rake/, "mini_portile2"]
   }

   # attributes
   attr_reader :source_file, :replace_list, :skip_list, :append_list, :spec

   def gemfiles
      return @gemfiles if @gemfiles

      gemfiles = dsl.instance_variable_get(:@gemfiles) || []

      @gemfiles = gemfiles.map {|g| g.is_a?(Pathname) && g || Pathname.new(g) }
   end

   def gemfile
      gemfiles.first || original_gemfile || fake_gemfile_path
   end

   def original_gemfile
      @original_gemfile ||= is_source_gemfile && Pathname.new(source_file) || find_gemfile
   end

   def is_source_gemfile
      source_file =~ /Gemfile$/i
   end

   def find_gemfile
      gemfile = source_file && Dir[File.join(File.dirname(source_file), '{Gemfile,gemfile}')].first

      gemfile && Pathname.new(gemfile) || nil
   end

   def fake_gemfile_path
      if !@fake_gemfile && @fake_gemfile ||= Tempfile.create('Gemfile')
         @fake_gemfile_path = @fake_gemfile.path

         Bundler::SharedHelpers.set_env "BUNDLE_GEMFILE", @fake_gemfile_path
         @fake_gemfile.close
      end

      @fake_gemfile_path
   end

   def fake_gemlock_path
      if !@fake_gemlock && @fake_gemlock ||= Tempfile.create('Gemfile.lock')
         @fake_gemlock_path = @fake_gemlock.path

         @fake_gemlock.close
      end

      @fake_gemlock_path
   end

   def dsl
      @dsl ||= (
         begin
            dsl =
               Dir.chdir(File.dirname(source_file)) do
                  dsl = Bundler::Dsl.new
                  dsl.eval_gemfile(original_gemfile)
                  dsl
               end
         rescue LoadError,
                TypeError,
                Bundler::GemNotFound,
                Bundler::GemfileNotFound,
                Bundler::VersionConflict,
                Bundler::Dsl::DSLError,
                Errno::ENOENT,
                ::Gem::InvalidSpecificationException => e

            dsl = Bundler::Dsl.new
            dsl.instance_variable_set(:@gemfiles, [Pathname.new(fake_gemfile_path)])
            dsl.to_definition(fake_gemlock_path, {})
            Bundler::SharedHelpers.set_env "BUNDLE_GEMFILE", nil

            dsl
         end)
   end

   def edsl
      @edsl ||= (
         begin
            edsl = dsl.dup
            edsl.dependencies = deps_but(dsl.dependencies)
            edsl
         end)
   end

   def definition
      @definition ||=
         Dir.mktmpdir do
            FileUtils.touch("Gemfile")

            edsl.to_definition("./Gemfile", {})
         end
   end

   def external_dependencies
      return [] unless source_file

      dir = File.dirname(source_file)

      (Gem::DependencyInstaller.instance_variable_get(:@deps) || []).map do |(path, dep)|
         if path[0...dir.size] == dir
            Bundler::Dependency.new(dep.name, dep.requirement, "group" => :development)
         end
      end.compact
   end

   def spec_dependencies
      (spec&.dependencies || []).map do |dep|
         group_in = DEFAULT_GEM_GROUP.select {|g, list| list.find {|r| r === dep.name }}&.keys&.first || :test
         options = {
            "group" => dep.type == :development ? [group_in] : [:runtime, group_in],
            "platforms" => dep.respond_to?(:platforms) ? dep.platforms : []
         }

         Bundler::Dependency.new(dep.name, dep.requirement, options)
      end
   end

   def original_deps_for kinds_in = nil
      groups = self.class.defined_groups_for(kinds_in)

      original_deps.select do |dep|
         (dep.groups & groups).any? &&
         (dep.platforms.blank? || dep.platforms.any? {|p| PLATFORMS[p] })
      end
   end

   def all_dependencies
      dsl.dependencies | spec_dependencies | external_dependencies
   end

   def all_dependencies_for kinds_in: [], kinds_out: []
      groups_out = Baltix::DSL.defined_groups_for(kinds_out)
      groups_in = Baltix::DSL.defined_groups_for(kinds_in) - groups_out

      all_dependencies.select do |dep|
         (dep.groups & groups_in).any? && !(dep.groups & groups_out).any? &&
         (dep.platforms.blank? || dep.platforms.any? {|p| PLATFORMS[p] })
      end
   end

   def original_deps
      @original_deps ||= all_dependencies.map do |dep|
         type = dep.groups.map {|g| GROUP_MAPPING[g]}.compact.flatten.uniq.sort.first || dep.type
         dep.instance_variable_set(:@type, type)
         valid = !dep.source.is_a?(Bundler::Source::Path)

         valid && dep || nil
      end.compact
   end

   def gemspecs
      spec ? [spec] : dsl.gemspecs
   end

   def extracted_gemspec_deps
      gemspecs.map { |gs| gs.dependencies }.flatten.uniq
   end

   def extracted_gemspec_runtime_deps
      gemspecs.map do |gs|
         gs.dependencies.select {|dep|dep.runtime?}
      end.flatten.uniq
   end

   def runtime_deps kind = :gemspec
      if kind == :gemspec
         deps_but(extracted_gemspec_runtime_deps)
      else
         deps_but(original_deps_for(:runtime))
      end
   end

   def development_deps kind = :gemspec
      deps_but(original_deps_for(:devel))
   end

   class << self
      def match_kind_dep dep, *kinds_in
         groups = defined_groups_for(kinds_in)

         (dep.groups & groups).any?
      end

      def defined_groups_for *kinds_in
         kinds_in.flatten.map do |k|
            GROUP_MAPPING.map do |(g, k_in)|
               [k_in].flatten.include?(k) && g || nil
            end.compact
         end.flatten.select {|x| x.is_a?(Symbol) }
      end

      def merge_dependencies *depses
         depses.reduce({}) do |res, deps|
            deps.reduce(res.dup) do |r, x|
               r[x.name] =
                  if r[x.name]
                     req = r[x.name].requirement.merge(x.requirement)

                     r[x.name].class.new(x.name, req, "type" => r[x.name].type)
                  else
                     x
                  end

               r
            end
         end.values
      end

      def filter_dependencies type, *depses
         depses.map { |deps| deps.select {|x|x.type == type }}
      end
   end

   def dependencies type = nil
      if type
         self.class.merge_dependencies(*self.class.filter_dependencies(type, definition.dependencies, spec.dependencies))
      else
         self.class.merge_dependencies(definition.dependencies, spec.dependencies)
      end
   end

   def deps
      deps_but(original_deps) | gemspec_deps
   end

   def gemspec_deps
      gemspecs.map do |gs|
         version = gs.version || Gem::Version.new(0)
         Gem::Dependency.new(gs.name, Gem::Requirement.new(["= #{version}"]), :devel)
      end
   end

   def deps_for kinds_in = nil
      deps_but(original_deps_for(kinds_in)) | gemspec_deps
   end

   def required_rubies
      return @required_rubies if @required_rubies

      rubies = {}
      rubies["ruby"] = spec.required_ruby_version if spec
      dsl_ruby = dsl.instance_variable_get(:@ruby_version)
      rubies = rubies.deep_merge(dsl_ruby.engine => dsl_ruby.engine_version) if dsl_ruby

      @required_rubies = rubies
   end

   def required_rubygems
      return @required_rubygems if @required_rubygems

      rubygems = spec.required_rubygems_version if spec
      dsl_rubygems = dsl.instance_variable_get(:@rubygems_version)
      rubygems = rubygems ? rubygems.merge(dsl_rubygems) : dsl_rubygems if dsl_rubygems

      @required_rubygems = rubygems || Gem::Requirement.new([">= 0"])
   end
 
   def ruby
      { type: required_ruby, version: required_ruby_version }
   end

   def rubygems
      { version: required_rubygems_version }
   end

   def valid?
      gemfiles.any? {|g| g.eql?(original_gemfile) }
   end

   def to_ruby
      spec = self.spec.dup
      deps_in = deps_but(extracted_gemspec_deps)
      deps = spec.dependencies.map {|x| deps_in.find {|a| a.name == x.name }}.compact
      spec.dependencies.replace(deps)
      spec.to_ruby
   end

   def to_gemfile
      deps_but(original_deps).group_by { |d| d.name }.map do |name, deps|
         reqs = deps.map do |dep|
            reqs = dep.requirement.requirements.map {|r| "'#{r[0]} #{r[1]}'" }.join(", ")
         end.join(", ")

         dep = deps.first
         autoreq = dep.respond_to?(:autorequire) &&
                   dep.autorequire &&
                   "require: #{dep.autorequire.any? &&
                             "[" + dep.autorequire.map { |r| r.inspect }.join(', ') + "]" ||
                             "false"}" || nil
         groups = dep.respond_to?(:groups) && dep.groups || []
         g = groups - [ :default ]
         group_list = g.any? && "group: %i(#{groups.join("\n")})" || nil

         [ "gem '#{name}'", reqs, autoreq, group_list ].compact.join(', ')
      end.join("\n")
   end

   def required_rubygems_version
      ">= 0"
   end

   def required_ruby_version
      @required_ruby_version ||= Gem::Requirement.new(dsl.instance_variable_get(:@ruby_version)&.engine_versions || ">= 0")
   end

   def required_ruby
      @required_ruby ||= dsl.instance_variable_get(:@ruby_version)&.engine || "ruby"
   end

   def merge_in other_dsl
      if original_gemfile.to_s != other_dsl.original_gemfile.to_s
         hodeps = other_dsl.original_deps.map {|dep| [dep.name, dep] }.to_h
         original_deps.map {|dep| [dep.name, dep] }.to_os.deep_merge(hodeps).to_h.values.map do |dep|
            if dep.is_a?(Array)
               dep.reduce { |res, dep_in| res.merge(dep_in) }
            else
               dep
            end
         end
      end

      self
   end

   protected

   def deps_but deps
      deps.map do |dep|
         next if skip_list.include?(dep.name)

         new_req = replace_list.reduce(nil) do |s, (name, req)|
            s || name == dep.name && req
         end

         new_req && Bundler::Dependency.new(dep.name, Gem::Requirement.new([new_req]), "type" => dep.type) || dep
      end.compact | append_list
   end

   #
   def initialize source_file, options = {}
      # TODO source_file is null for Fake source
      # raise unless source_file && File.file?(source_file)

      @source_file = source_file
      @spec = options[:spec]
      @replace_list = options[:replace_list] || {}
      @skip_list = options[:skip_list] || []
      @append_list = options[:append_list] || []
   end
end
