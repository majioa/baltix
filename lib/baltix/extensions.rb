module Extensions
   module Object
      def self.const_get c, inherit = true
         super
      rescue Exception => e
         begin
           require c.to_s.downcase
         rescue Exception => e
         end

         super
      end

      def blank?
         case self
         when ::NilClass, ::FalseClass
            true
         when ::TrueClass
            false
         when ::Hash, ::Array
            !self.any?
         else
            self.to_s == ""
         end
      end

      def to_os hash: false, array: false
         value =
           self.to_h.map do |(x, y_in)|
              y =
                 if hash && y_in.is_a?(Hash) || array && y_in.is_a?(Array)
                    y_in.to_os(hash: hash, array: array)
                 else
                    y_in
                 end

              [x.to_s, y]
            end.to_h

         ::OpenStruct.new(value)
      end
   end

   module Array
      # actjoin(array) => [<pre_match1>, <pre_match2>, <pre_match3>, <post_match>]; array = [match1, match2, match3]
      #
      def actjoin array
         self.map.with_index { |x, i| [ x, array[i] ].compact }.flatten.join
      end
   end

   module OpenStruct
      def to_os
         self
      end

      def merge_to other
         ::OpenStruct.new(other.to_os.deep_merge(self))
      end

      def merge other
         ::OpenStruct.new(self.to_os.deep_merge(other))
      end

      def map *args, &block
         res = self.class.new

         self.each_pair do |key, value|
            res[key] = block[key, value]
         end

         res
      end

      def select &block
         res = self.class.new

         self.each_pair do |key, value|
            res[key] = value if block[key, value]
         end

         res
      end

      def compact
         select { |_, value| !value.blank? }
      end

      def each *args, &block
         self.each_pair(*args, &block)
      end

      def reduce default = nil, &block
         res = default

         self.each_pair do |key, value|
            res = block[res, key, value]
         end

         res
      end

      def find &block
         select(&block).first
      end

      def replace new_os
         self.to_h.keys.each {|x| self[x] = nil }

         new_os.to_os.each {|x, v| self[x] = v }

         self
      end

      def deep_dup
         self.reduce({}.to_os) do |r, x, y|
            r[x] = y.respond_to?(:deep_dup) ? y.deep_dup : y.dup

            r
         end
      end

      # +deep_merge+ deeply merges the Open Struct hash structure with the +other_in+ enumerating it key by key.
      # +options+ are the options to change behaviour of the method. It allows two keys: :mode, and :dedup
      # :mode key can be :append, :prepend, or :replace, defaulting to :append, when mode is to append, it combines duplicated
      # keys' values into an array, when :prepend it prepends an other value before previously stored one unlike for :append mode,
      # when :replace it replace duplicate values with a last ones.
      # :dedup key can be true, or false. It allows to deduplicate values when appending or prepending values.
      # Examples:
      #    open_struct.deep_merge(other_open_struct)
      #    open_struct.deep_merge(other_open_struct, :prepend)
      #
      def deep_merge other_in, options_in = {}
         return self if other_in.nil? or other_in.blank?

         options = { mode: :replace }.merge(options_in)

         other =
            if other_in.is_a?(::OpenStruct)
               other_in.deep_dup
            elsif other_in.is_a?(::Hash)
               other_in.to_os
            else
               ::OpenStruct.new(nil => other_in.dup)
            end

         other.reduce(self.to_os.dup) do |res, key, value|
            res[key] =
               if res.table.keys.include?(key)
                  case value
                  when ::Hash
                     value.to_os.deep_merge(res[key].to_os, options).to_h.stringify_keys
                  when ::OpenStruct
                     value.deep_merge(res[key].to_os, options)
                  when ::Array
                     value | [res[key]].compact.flatten(1)
                  when ::NilClass
                     res[key]
                  else
                     value_out =
                        if options[:mode] == :append
                           [value, res[key]].compact.flatten(1).uniq
                        elsif options[:mode] == :prepend
                           [res[key], value].compact.flatten(1).uniq
                        else
                           value
                        end

                     if value_out.is_a?(Array) && options[:dedup]
                        value_out.uniq
                     else
                        value_out
                     end
                  end
               else
                  value
               end

            res
         end
      end
   end

   module GemRequirement
      INVALID_DEP = ["<", Gem::Version.new(0)] #:nodoc:

      AND_RELAS = { #:nodoc:
         [ "=", ">=", 0 ] => ->(l, r) { [["=", l]] },
         [ "=", ">=", 1 ] => ->(l, r) { [["=", l]] },
         [ "=", "<=", -1 ] => ->(l, r) { [["=", l]] },
         [ "=", "<=", 0 ] => ->(l, r) { [["=", l]] },
         [ "=", ">", 1 ] => ->(l, r) { [["=", l]] },
         [ "=", "<", -1 ] => ->(l, r) { [["=", l]] },
         [ "=", "=", 0 ] => ->(l, r) { [["=", l]] },
         [ "=", "~>", 0 ] => ->(l, r) { [["=", l]] },
         [ "=", "~>", ->(l, r) { l > r && l < r.bump } ] => ->(l, r) { [["=", l]] },
         [ "!=", "=", -1 ] => ->(l, r) { [["=", r]] },
         [ "!=", "=", 1 ] => ->(l, r) { [["=", r]] },
         [ "!=", "!=", -1 ] => ->(l, r) { [["!=", l]] },
         [ "!=", "!=", 0 ] => ->(l, r) { [["!=", l]] },
         [ "!=", "!=", 1 ] => ->(l, r) { [["!=", l]] },
         [ "!=", ">", -1 ] => ->(l, r) { [[">", r]] },
         [ "!=", ">", 0 ] => ->(l, r) { [[">", r]] },
         [ "!=", ">", 1 ] => ->(l, r) { [[">", r], ["<", l]] },
         [ "!=", "<", -1 ] => ->(l, r) { [[">", l], ["<", r]] },
         [ "!=", "<", 0 ] => ->(l, r) { [["<", r]] },
         [ "!=", "<", 1 ] => ->(l, r) { [["<", r]] },
         [ "!=", ">=", -1 ] => ->(l, r) { [[">=", r]] },
         [ "!=", ">=", 0 ] => ->(l, r) { [[">", r]] },
         [ "!=", ">=", 1 ] => ->(l, r) { [[">=", r], ["<", l]] },
         [ "!=", "<=", -1 ] => ->(l, r) { [[">", l], ["<=", r]] },
         [ "!=", "<=", 0 ] => ->(l, r) { [["<", r]] },
         [ "!=", "<=", 1 ] => ->(̀r, l) { [["<=", r]] },
         [ "!=", "~>", -1 ] => ->(l, r) { [[">=", r], ["<", r.bump]] },
         [ "!=", "~>", 0 ] => ->(l, r) { [[">", r], ["<", r.bump]] },
         [ "!=", "~>", ->(l, r) { l > r && l < r.bump } ] => ->(l, r) { [[">", l], ["<", r.bump]] },
         [ "!=", "~>", ->(l, r) { l >= r.bump } ] => ->(l, r) { [[">=", l]] },
         [ ">", "=", -1 ] => ->(l, r) { [["=", r]] },
         [ ">", "!=", -1 ] => ->(l, r) { [[">", l], ["<", r]] },
         [ ">", "!=", 0 ] => ->(l, r) { [[">", l]] },
         [ ">", "!=", 1 ] => ->(l, r) { [[">", l]] },
         [ ">", ">", -1 ] => ->(l, r) { [[">", [r, l].max]] },
         [ ">", ">=", -1 ] => ->(l, r) { [[">=", l]] },
         [ ">", ">=", 0 ] => ->(l, r) { [[">", l]] },
         [ ">", ">=", 1 ] => ->(l, r) { [[">", l]] },
         [ ">", "<=", -1 ] => ->(l, r) { [[">", l], ["<=", r]] },
         [ ">", "~>", -1 ] => ->(l, r) { [[">=", l], ["<", r.bump]] },
         [ ">", "~>", 0 ] => ->(l, r) { [[">", l], ["<", r.bump]] },
         [ ">", "~>", ->(l, r) { l > r && l < r.bump } ] => ->(l, r) { [[">", l], ["<", r.bump]] },
         [ ">", "~>", ->(l, r) { l >= r.bump } ] => ->(l, r) { [[">", l]] },
         [ "<", "=", 1 ] => ->(l, r) { [["=", r]] },
         [ "<", "!=", -1 ] => ->(l, r) { [["<", l]] },
         [ "<", "!=", 0 ] => ->(l, r) { [["<", l]] },
         [ "<", "!=", 1 ] => ->(l, r) { [[">=", r], ["<", l]] },
         [ "<", ">", 1 ] => ->(l, r) { [[">", r], ["<", l]] },
         [ "<", "<", nil ] => ->(l, r) { [["<", [r, l].min]] },
         [ "<", ">=", 1 ] => ->(l, r) { [[">=", r], ["<", l]] },
         [ "<", "~>", 1 ] => ->(l, r) { [[">=", r], ["<", [l, r.bump].min]] },
         [ ">=", "=", -1 ] => ->(l, r) { [["=", r]] },
         [ ">=", "=", 0 ] => ->(l, r) { [["=", r]] },
         [ ">=", "!=", -1 ] => ->(l, r) { [[">=", l], ["<", r]] },
         [ ">=", "!=", 0 ] => ->(l, r) { [[">", l]] },
         [ ">=", "!=", 1 ] => ->(l, r) { [[">=", l]] },
         [ ">=", ">", -1 ] => ->(l, r) { [[">", r]] },
         [ ">=", ">", 0 ] => ->(l, r) { [[">", r]] },
         [ ">=", ">", 1 ] => ->(l, r) { [[">=", l]] },
         [ ">=", "<", -1 ] => ->(l, r) { [[">=", l], ["<", r]] },
         [ ">=", ">=", nil ] => ->(l, r) { [[">=", [r, l].max]] },
         [ ">=", "<=", -1 ] => ->(l, r) { [[">=", l], ["<=", r]] },
         [ ">=", "<=", 0 ] => ->(l, r) { [["=", l]] },
         [ ">=", "~>", ->(l, r) { l < r.bump } ] => ->(l, r) { [[">=", [r, l].max], ["<", r.bump]] },
         [ "<=", "=", 0 ] => ->(l, r) { [["=", r]] },
         [ "<=", "=", 1 ] => ->(l, r) { [["=", r]] },
         [ "<=", "!=", -1 ] => ->(l, r) { [["<=", l]] },
         [ "<=", "!=", 0 ] => ->(l, r) { [["<=", l]] },
         [ "<=", "!=", 1 ] => ->(l, r) { [[">", r], ["<=", l]] },
         [ "<=", ">", 1 ] => ->(l, r) { [[">", r], ["<=", l]] },
         [ "<=", "<", -1 ] => ->(l, r) { [["<=", l]] },
         [ "<=", "<", 0 ] => ->(l, r) { [["<", l]] },
         [ "<=", "<", 1 ] => ->(l, r) { [["<", r]] },
         [ "<=", ">=", 0 ] => ->(l, r) { [["=", l]] },
         [ "<=", ">=", 1 ] => ->(l, r) { [[">=", r], ["<=", l]] },
         [ "<=", "~>", ->(l, r) { r.bump > l } ] => ->(l, r) { [[">=", r], ["<", r.bump]] },
         [ "<=", "~>", ->(l, r) { r >= l && r.bump <= l } ] => ->(l, r) { [[">=", r], ["<=", l]] },
         [ "~>", "=", 0 ] => ->(l, r) { [["=", r]] },
         [ "~>", "=", ->(l, r) { l.bump > r } ] => ->(l, r) { [["=", r]] },
         [ "~>", "!=", ->(l, r) { l.bump >= r } ] => ->(l, r) { [[">=", l], ["<", l.bump]] },
         [ "~>", "!=", ->(l, r) { l > r && l.bump < r } ] => ->(l, r) { [[">=", l], ["<", r]] },
         [ "~>", "!=", 0 ] => ->(l, r) { [[">", l], ["<", l.bump]] },
         [ "~>", "!=", 1 ] => ->(l, r) { [[">=", l], ["<", l.bump]] },
         [ "~>", ">", ->(l, r) { l < r && l.bump >= r } ] => ->(l, r) { [[">", r], ["<", l.bump]] },
         [ "~>", ">", 0 ] => ->(l, r) { [[">", l], ["<", l.bump]] },
         [ "~>", ">", 1 ] => ->(l, r) { [[">=", l], ["<", l.bump]]},
         [ "~>", "<", nil ] => ->(l, r) { [[">=", l], ["<", [r, l.bump].max]] },
         [ "~>", ">=", ->(l, r) { l < r && l.bump >= r } ] => ->(l, r) { [[">=", r], ["<", l.bump]] },
         [ "~>", ">=", 0 ] => ->(l, r) { [[">=", l], ["<", l.bump]] },
         [ "~>", ">=", 1 ] => ->(l, r) { [[">=", l], ["<", l.bump]] },
         [ "~>", "<=", ->(l, r) { l < r && l.bump >= r } ] => ->(l, r) { [[">=", l], ["<=", r]] },
         [ "~>", "<=", ->(l, r) { l.bump < r } ] => ->(l, r) { [[">=", l], ["<", l.bump]] },
         [ "~>", "<=", 0 ] => ->(l, r) { [["=", l]] },
         [ "~>", "~>", ->(l, r) { l.bump >= r && l < r.bump || r.bump >= l && r < l.bump } ] => ->(l, r) { [[">=", [r, l].max], ["<", [r.bump, l.bump].min]] }
      }.freeze

      OR_RELAS = { #:nodoc:
         [ "=", ">=", nil ] => ->(l, r) { [[">=", [r, l].min]] },
         [ "=", "<=", -1 ] => ->(l, r) { [["<=", r]] },
         [ "=", "<=", 0 ] => ->(l, r) { [["<=", r]] },
         [ "=", ">", 0 ] => ->(l, r) { [[">=", r]] },
         [ "=", ">", 1 ] => ->(l, r) { [[">", r]] },
         [ "=", "<", -1 ] => ->(l, r) { [["<", r]] },
         [ "=", "<", 0 ] => ->(l, r) { [["<=", r]] },
         [ "=", "=", 0 ] => ->(l, r) { [["=", l]] },
         [ "=", "~>", nil ] => ->(l, r) { [[">=", [r, l].min], ["<", r.bump]] },
         [ "!=", "=", -1 ] => ->(l, r) { [["=", r], ["!=", l]] },
         [ "!=", "=", 0 ] => ->(l, r) { [] },
         [ "!=", "=", 1 ] => ->(l, r) { [["=", r], ["!=", l]] },
         [ "!=", "!=", 0 ] => ->(l, r) { [["!=", l]] },
         [ "!=", ">", -1 ] => ->(l, r) { [[">", r]] },
         [ "!=", ">", 0 ] => ->(l, r) { [[">", r]] },
         [ "!=", ">", 1 ] => ->(l, r) { [[">", r], ["!=", l]] },
         [ "!=", "<", -1 ] => ->(l, r) { [["<", r], ["!=", l]] },
         [ "!=", "<", 0 ] => ->(l, r) { [["<", r]] },
         [ "!=", "<", 1 ] => ->(l, r) { [["<", r]] },
         [ "!=", ">=", -1 ] => ->(l, r) { [[">=", r]] },
         [ "!=", ">=", 0 ] => ->(l, r) { [[">", r]] },
         [ "!=", ">=", 1 ] => ->(l, r) { [[">=", r], ["!=", l]] },
         [ "!=", "<=", -1 ] => ->(l, r) { [["<=", r], ["!=", l]] },
         [ "!=", "<=", 0 ] => ->(l, r) { [["<", r]] },
         [ "!=", "<=", 1 ] => ->(̀r, l) { [["<=", r]] },
         [ "!=", "~>", -1 ] => ->(l, r) { [[">=", r], ["<", r.bump], ["!=", l]] },
         [ "!=", "~>", 0 ] => ->(l, r) { [[">", r], ["<", r.bump]] },
         [ "!=", "~>", 1 ] => ->(l, r) { [[">=", r], ["<", r.bump], ["!=", l]] },
         [ ">", "=", 0 ] => ->(l, r) { [[">=", l]] },
         [ ">", "=", 1 ] => ->(l, r) { [[">", l]] },
         [ ">", "!=", 0 ] => ->(l, r) { [[">", l]] },
         [ ">", "!=", 1 ] => ->(l, r) { [[">", l]] },
         [ ">", ">", nil ] => ->(l, r) { [[">", [r, l].min]] },
         [ ">", "<", 0 ] => ->(l, r) { [] },
         [ ">", "<", 1 ] => ->(l, r) { [] },
         [ ">", ">=", -1 ] => ->(l, r) { [[">", l]] },
         [ ">", ">=", 0 ] => ->(l, r) { [[">=", r]] },
         [ ">", ">=", 1 ] => ->(l, r) { [[">=", r]] },
         [ ">", "<=", 0 ] => ->(l, r) { [] },
         [ ">", "<=", 1 ] => ->(l, r) { [] },
         [ ">", "~>", -1 ] => ->(l, r) { [[">", l], ["<", r.bump]] },
         [ ">", "~>", 0 ] => ->(l, r) { [[">=", r], ["<", r.bump]] },
         [ ">", "~>", 1 ] => ->(l, r) { [[">=", r], ["<", r.bump]] },
         [ "<", "=", 0 ] => ->(l, r) { [["<=", l]] },
         [ "<", "=", 1 ] => ->(l, r) { [["<", l]] },
         [ "<", "!=", -1 ] => ->(l, r) { [["<", l]] },
         [ "<", "!=", 0 ] => ->(l, r) { [["<", l]] },
         [ "<", ">", -1 ] => ->(l, r) { [] },
         [ "<", ">", 0 ] => ->(l, r) { [] },
         [ "<", ">", 1 ] => ->(l, r) { [[">", r], ["<", l]] },
         [ "<", "<", nil ] => ->(l, r) { [["<", [r, l].max]] },
         [ "<", ">=", -1 ] => ->(l, r) { [] },
         [ "<", ">=", 0 ] => ->(l, r) { [] },
         [ "<", ">=", 1 ] => ->(l, r) { [[">=", r], ["<", l]] },
         [ "<", "~>", nil ] => ->(l, r) { [[">=", r], ["<", [l, r.bump].max]] },
         [ ">=", "=", 0 ] => ->(l, r) { [[">=", l]] },
         [ ">=", "=", -1 ] => ->(l, r) { [[">=", l], ["=", r]] },
         [ ">=", "!=", 0 ] => ->(l, r) { [[">", l]] },
         [ ">=", "!=", 1 ] => ->(l, r) { [[">=", l]] },
         [ ">=", ">", -1 ] => ->(l, r) { [[">=", l]] },
         [ ">=", ">", 0 ] => ->(l, r) { [[">=", l]] },
         [ ">=", ">", 1 ] => ->(l, r) { [[">", r]] },
         [ ">=", "<", 0 ] => ->(l, r) { [] },
         [ ">=", "<", 1 ] => ->(l, r) { [] },
         [ ">=", ">=", nil ] => ->(l, r) { [[">=", [r, l].min]] },
         [ ">=", "<=", 0 ] => ->(l, r) { [["=", l]] },
         [ ">=", "<=", 1 ] => ->(l, r) { [] },
         [ ">=", "~>", nil ] => ->(l, r) { [[">=", [r, l].min], ["<", r.bump]] },
         [ "<=", "=", 0 ] => ->(l, r) { [["<=", l]] },
         [ "<=", "=", 1 ] => ->(l, r) { [["<=", l]] },
         [ "<=", "!=", -1 ] => ->(l, r) { [["<", l]] },
         [ "<=", "!=", 0 ] => ->(l, r) { [["<", l]] },
         [ "<=", ">", -1 ] => ->(l, r) { [] },
         [ "<=", ">", 0 ] => ->(l, r) { [] },
         [ "<=", ">", 1 ] => ->(l, r) { [[">", r], ["<=", l]] },
         [ "<=", "<", -1 ] => ->(l, r) { [["<=", l]] },
         [ "<=", "<", 0 ] => ->(l, r) { [["<=", l]] },
         [ "<=", "<", 1 ] => ->(l, r) { [["<", r]] },
         [ "<=", ">=", -1 ] => ->(l, r) { [] },
         [ "<=", ">=", 0 ] => ->(l, r) { [["=", l]] },
         [ "<=", ">=", 1 ] => ->(l, r) { [[">=", r], ["<=", l]] },
         [ "<=", "~>", ->(l, r) { r.bump > l } ] => ->(l, r) { [[">=", r], ["<", r.bump]] },
         [ "<=", "~>", ->(l, r) { r.bump <= l } ] => ->(l, r) { [[">=", r], ["<=", l]] },
         [ "~>", "=", nil ] => ->(l, r) { [[">=", [l, r].min], ["<", l.bump]] },
         [ "~>", "!=", -1 ] => ->(l, r) { [[">=", l], ["<", l.bump], ["!=", r]] },
         [ "~>", "!=", 0 ] => ->(l, r) { [[">", l], ["<", l.bump]] },
         [ "~>", "!=", 1 ] => ->(l, r) { [[">=", l], ["<", l.bump], ["!=", r]] },
         [ "~>", ">", -1 ] => ->(l, r) { [[">=", l], ["<", l.bump]] },
         [ "~>", ">", 0 ] => ->(l, r) { [[">=", l], ["<", l.bump]] },
         [ "~>", ">", 1 ] => ->(l, r) { [[">", r], ["<", l.bump]]},
         [ "~>", "<", nil ] => ->(l, r) { [[">=", l], ["<", [r, l.bump].max]] },
         [ "~>", ">=", nil ] => ->(l, r) { [[">=", [l, r].min], ["<", l.bump]] },
         [ "~>", "<=", ->(l, r) { l.bump > r } ] => ->(l, r) { [[">=", l], ["<", l.bump]] },
         [ "~>", "<=", ->(l, r) { l.bump <= r } ] => ->(l, r) { [[">=", l], ["<=", r]] },
         [ "~>", "~>", nil ] => ->(l, r) { [[">=", [r, l].min], ["<", [r.bump, l.bump].max]] }
      }.freeze

      def | other_requirement
         self.expand_requirements(self.requirements | other_requirement.requirements)
      end

      def expand
         self.expand_requirements(self.requirements)
      end

      def expand_requirements requirements
         reqs_in = []
         res = requirements.dup

         #binding.pry
         while reqs_in != res do
            reqs_in = res
            reqs = reqs_in.dup
            res = []

            #binding.pry
            while !reqs.empty? do
               op1, ver1 = reqs.shift
               op2, ver2 = reqs.shift || [op1, ver1]

               prc =
                  Gem::Requirement::OR_RELAS.find do |((left, right, comp), _)|
                     match = op1 == left && op2 == right &&
                        case comp
                        when NilClass
                           true
                        when Integer
                           comp == (ver1 <=> ver2)
                        when Proc
                           comp[ver1, ver2]
                        end
                  end

               #binding.pry
               res =
                  if prc
                     res.concat(prc.last[ver1, ver2])
                  elsif reqs.empty?
                     res.concat([[op1, ver1], [op2, ver2]])
                  else
                     #binding.pry
                     reqs.unshift([op2, ver2])
                     res.concat([[op1, ver1]])
                  end
            end
         end

         #binding.pry
         Gem::Requirement.new(res.map {|x|x.join(" ")})
      end

      # merging gem requirement with others strictizing the conditions
      def merge other_requirement
         reqs_pre = self.requirements | other_requirement.requirements
         reqs_tmp = []

         while reqs_tmp != reqs_pre
            reqs_tmp = reqs_pre
            reqs_pre =
               reqs_tmp[1..-1].reduce([reqs_tmp.first]) do |res, req|
                  op1, ver1 = res.last
                  op2, ver2 = req

                  prc =
                     Gem::Requirement::AND_RELAS.find do |((left, right, comp), _)|
                        match = op1 == left && op2 == right &&
                           case comp
                           when NilClass
                              true
                           when Integer
                              comp == (ver1 <=> ver2)
                           when Proc
                              comp[ver1, ver2]
                           end
                     end

                  res[0...-1] | prc ? prc.last[ver1, ver2] : [INVALID_DEP]
            end
         end

         # binding.pry
         Gem::Requirement.new(reqs_pre.map {|x|x.join(" ")})
      end
   end

   module String
      def snakeize
         resIn = self.gsub(/::/, '-')

         self.unpack("U*").reduce("") do |res, _|
            break res if resIn.blank?

            m = resIn.match(/[A-Z]+[^A-Z\-]*/)
            r = res + resIn[m.begin(0)...m.end(0)].downcase + (resIn[m.end(0)] == '-' ? "-" : m.end(0) != resIn.size ? "_" : "")
            resIn = resIn[m.end(0)..-1].gsub(/::/, '-')

            r
         end
      end

      def constantize
         self.split('::').reduce(Object) do |c, token|
           token.empty? && c || c.const_get(token)
         end
      end
   end

   module Kernel
      def yaml_load text
         if Gem::Version.new(Psych::VERSION) >= Gem::Version.new("4.0.0")
            YAML.load(text, aliases: true, permitted_classes:
               [Gem::Specification,
                Gem::Version,
                Gem::Dependency,
                Gem::Requirement,
                Symbol,
                OpenStruct,
                Time,
                Date])
         else
            YAML.load(text)
         end
      end
   end
end
