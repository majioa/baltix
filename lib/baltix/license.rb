module Baltix::License
   LIST = {
      "AFL-1.2" => /AFL-1\.1/,
      "AFL-1.2" => /AFL-1\.2/,
      "AFL-1.2" => /AFL-2\.0/,
      "AFL-1.2" => /AFL-2\.1/,
      "AFL-1.2" => /AFL-3\.0/,
      "AFL-3.0" => /AFL/,
      "Apache-2.0" => /Apache[\-\s]2(\.0|).*/,
   }
   class << self
      def parse license
         LIST.reduce(nil) do |lic, (l, re)|
            lic || re =~ license && l
         end || license
      end
   end
end
