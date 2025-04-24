module Baltix::Loader::Extconf
   def specifics
      @@specifics ||= {}
   end

   def ext_file file, rootdir
      dir = File.dirname(file)
      Dir.chdir(dir) do
         mods[file] ||= load_file(file, rootdir)

         specifics[file] = {
            gems: mods[file].gems || [],
            requires: mods[file].requires || []
         }
      end

      nil
   end
end
