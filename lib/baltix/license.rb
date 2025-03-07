module Baltix::License
   LIST = {
      "AFL-1.2" => [
         /AFL-1\.1/,
         /AFL-1\.2/,
         /AFL-2\.0/,
         /AFL-2\.1/,
         /AFL-3\.0/],
      "AFL-3.0" => /AFL.*3\.0/,
      "Apache-2.0" => /Apache[\-\s]2(\.0|).*/,
   }
   class << self
      def parse license
         LIST.reduce(nil) do |lic, (l, reos)|
            [reos].flatten.reduce(lic) do |lic_in, re|
               lic_in || re =~ license && l
            end
         end || license
      end
   end
end
