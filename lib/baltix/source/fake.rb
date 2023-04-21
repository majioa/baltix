class Baltix::Source::Fake < Baltix::Source::Base
   def dsl
      @dsl ||=
         Baltix::DSL.new(source_file,
         replace_list: replace_list,
         skip_list: (options[:gem_skip_list] || []) | [self.name],
         append_list: options[:gem_append_list])
   end

   def valid?
      true
   end
end
