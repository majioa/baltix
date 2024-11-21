class Baltix::Spec::Rpm::Secondary
   attr_reader :source, :host, :source, :doc

   STATE = {
      name: {
         seq: %w(of_options of_source of_state of_default >_name >_local_rename),
         default: "",
      },
      pre_name: {
         seq: %w(of_options of_state of_default >_pre_name),
         default: "",
      },
      epoch: {
         seq: %w(of_options of_state),
         default: nil,
      },
      version: {
         seq: %w(of_options of_source of_state of_default >_reversion >_version),
         default: ->(_) { Time.now.strftime("%Y%m%d") },
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
         seq: %w(of_options >_group),
         default: ->(this) { Baltix::I18n.t("spec.rpm.#{this.kind}.group") },
      },
      devel_dependencies: {
         seq: %w(of_options of_state of_default >_prepare_dependencies >_devel_dependencies >_replace_versioning_dependencies >_dependencies_sort),
         default: [],
      },
      binary_dependencies: {
         seq: %w(of_options of_state of_default >_prepare_dependencies >_binary_dependencies >_replace_versioning_dependencies >_dependencies_sort),
         default: [],
      },
      runtime_dependencies: {
         seq: %w(of_options of_state of_default >_prepare_dependencies >_runtime_dependencies >_dependencies_sort),
         default: [],
      },
      requires: {
         seq: %w(of_options of_state of_default >_requires_plain_only >_requires_ruby >_requires_rubygems |_host_require |_kind_deps >_render_bottom_dep),
         default: [],
      },
      conflicts: {
         seq: %w(of_options of_state of_default >_conflicts_plain_only >_conflicts_ruby |_kind_deps >_render_top_dep),
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
      compilables: {
         seq: %w(of_options of_state of_source),
         default: [],
      },
      descriptions: {
         seq: %w(of_options of_state of_source of_default >_proceed_description >_descriptions >_format_descriptions),
         default: {}
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
      context: {
         seq: %w(of_options of_state),
         default: {},
      },
      dependencies: {
         seq: %w(of_options of_state of_source),
         default: []
      },
      gem_versionings: {
         seq: %w(of_options of_state >_gem_versionings),
         default: []
      },
      available_gem_list: {
         seq: %w(of_options of_state >_available_gem_list),
         default: {}.to_os
      },
      available_gem_ranges: {
         seq: %w(of_options of_state >_available_gem_ranges),
         default: {}
      },
      use_gem_obsolete_list: {
         seq: %w(of_options of_state),
         default: {}.to_os
      },
      rootdir: {
         seq: %w(of_options of_state),
         default: nil
      }
   }.to_os(hash: true)

   include Baltix::Spec::Rpm::SpecCore

   def resourced_from secondary
      @kind = secondary.kind.to_sym
      @doc = secondary.doc
      @source = secondary.source

      self
   end

   def state_kind
      return @state_kind if @state_kind

      # binding.pry
      @state_kind ||= options.source.is_a?(Baltix::Source::Gem) && "lib" || file_list.blank? && "app" || pre_name&.kind
   end

   def default_state_kind
      "app"
   end

   def kind
      @kind ||= source.is_a?(Baltix::Source::Gem) && :lib || :app
   end

   def names
      doc.names
   end

   protected

   def _group value_in
      value_in || (is_exec? || is_app?) && of_state(:group)
   end

   def _release _value_in
      doc.changes.last.release
   end

   def initialize doc: raise, source: nil, host: nil, kind: nil, state: {}, options: {}
      @source = source
      @doc = doc
      @host = host
      @kind = kind&.to_sym || self.kind
      @state = state.to_os
      @options = options.to_os
   end
end
