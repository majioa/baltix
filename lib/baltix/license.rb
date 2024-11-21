module Baltix::License
   LIST = {
      "AFL" => /AFL/
   }
   class << self
      def parse license
         LIST.reduce(nil) do |lic, (l, re)|
            lic || re =~ license && l
         end || license
      end
   end
end
