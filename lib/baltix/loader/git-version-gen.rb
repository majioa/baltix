# GIT-VERSION-GEN version generator based gemspec preparser
# example: "kgio" gem
#
module Baltix::Loader::GitVersionGen
   def git_version_gen execfile, _dir
      IO.popen(execfile) do |io|
         debug(io.readlines)
      end

      dir = File.dirname(execfile)
      Dir.chdir(dir) do
         `#{execfile}`
         version_line = IO.read(File.join(dir, "GIT-VERSION-FILE"))
         if /=(?<version>.*)/ =~ version_line
            ENV["VERSION"] = version.strip
         end

         # dot manifest generation
         files = Dir["*/**/*"].select {|x| File.file?(x) }
         docs = files.select { |x| /(README.*|.*\.rb)/i =~ x }
         File.open(".manifest", "w+") { |f| f.puts(files.join("\n"))}
         File.open(".document", "w+") { |f| f.puts(docs.join("\n")) }

         # make documentaion
         if File.directory?('Documentation')
            `make -C Documentation`
         end

         if !File.exist?('.manifest') || !File.exist?('.gem-manifest')
            files = Dir.glob("**/*", File::FNM_DOTMATCH).reject do |f|
               /\/\.git/ =~ f || File.directory?(f)
            end

            File.open(File.join('.gem-manifest'), "w") { |f| f.puts files }
            FileUtils.cp('.gem-manifest', '.manifest')
         end
      end

      nil
   end
end
