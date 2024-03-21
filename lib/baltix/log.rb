module Baltix::Log
   DEFAULT_IO_NAMES = {
      none: nil,
      error: 'stderr',
      warn: 'stderr',
      info: 'stderr',
      debug: 'stderr',
   }

   DEFAULT_IO_NAMES.keys.each do |key|
      define_method(key) {|message| log(key, message) if level_match(key) }
   end

   def log kind, message
      Baltix::Log.ios[kind].puts("#{Baltix::Log.prefix[kind]}#{message}")
   end

   def level_match kind
      Baltix::Log.ios[kind] && Baltix::Log.ios.keys.index(kind) <= Baltix::Log.ios.keys.index(Baltix::Log.level)
   end

   class << self
      def prefix_for kind, prefix
         @@prefix[kind] = prefix
      end

      def prefix
         @@prefix ||= default_prefix(ios)
      end

      def default_prefix ios
         ios.keys.map {|kind| [kind, "[baltix][#{kind.upcase}]> " ] }.to_h
      end

      def setup_kind kind, io
         ios[kind] = io
      end

      def ios
         @@ios ||= io_name_parse(DEFAULT_IO_NAMES)
      end

      def level
         @@level ||= :info
      end

      def setup level = :info, io_names = DEFAULT_IO_NAMES, prefix = nil
         @@ios = io_name_parse(io_names)
         @@level = level
         @@prefix = prefix || default_prefix(ios)
      end

      def io_name_parse io_names
         io_names.map do |(kind, io_name)|
            io =
               case [io_name].flatten.first
               when '-', 'stdout'
                  $stdout
               when '--', 'stderr'
                  $stderr
               when '', nil
                  nil
               else
                  File.open(io_name, 'a+')
               end

            [kind, io]
         end.to_h
      end

      at_exit { (@@ios rescue {}).values.each {|v| v.close if v.is_a?(File) } }
   end
end
