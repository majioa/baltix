require 'baltix/dsl'
require 'baltix/source/base'

class Baltix::Source::Gemfile < Baltix::Source::Base
   class << self
      def search dir, options_in = {}
         Dir.glob("#{dir}/**/Gemfile", File::FNM_DOTMATCH).select {|f| File.file?(f) }.map do |f|
            self.new(source_options({ source_file: f }.to_os.merge(options_in)))
         end
      end
   end

   def gemfile_path
      gemspec_file = Tempfile.create('Gemfile.')
      gemspec_file.puts(dsl.to_gemfile)
      gemspec_file.rewind
      gemspec_file.path
   end

   def dsl
      @dsl ||=
         Baltix::DSL.new(source_file,
         replace_list: replace_list,
         skip_list: (options[:gem_skip_list] || []) | [self.name],
         append_list: options[:gem_append_list])
   end

   def valid?
      dsl.valid?
   end

   def rake
      @rake ||= Baltix::Rake.new(source_file)
   end
end
