module Extensions
   module Hash
      def to_os
         ::OpenStruct.new(self)
      end

      def deep_merge other, options_in = {}
         return self if other.nil? or other.blank?

         options = { mode: :append }.merge(options_in)

         other_hash = other.is_a?(Hash) && other || { nil => other }
         common_keys = self.keys & other_hash.keys
         base_hash = (other_hash.keys - common_keys).reduce({}) do |res, key|
            res[key] = other_hash[key]
            res
         end

         self.reduce(base_hash) do |res, (key, value)|
            new =
            if common_keys.include?(key)
               case value
               when Hash, OpenStruct
                  value.deep_merge(other_hash[key])
               when Array
                  value.concat([ other_hash[key] ].compact.flatten(1))
               when NilClass
                  other_hash[key]
               else
                  value_out =
                     if options[:mode] == :append
                        [other_hash[key], value].compact.flatten(1)
                     elsif options[:mode] == :prepend
                        [value, other_hash[key]].compact.flatten(1)
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

            res[key] = new
            res
         end
      end
   end

   module OpenStruct
      def to_os
         self
      end

      def merge_to other
         OpenStruct.new(other.to_h.merge(self.to_h))
      end

      def merge other
         OpenStruct.new(self.to_h.merge(other.to_h))
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

         options = { mode: :append }.merge(options_in)

         other =
            if other_in.is_a?(OpenStruct)
               other_in.dup
            elsif other_in.is_a?(Hash)
               other_in.to_os
            else
               OpenStruct.new(nil => other_in)
            end

         self.reduce(other) do |res, key, value|
            res[key] =
               if res.table.keys.include?(key)
                  case value
                  when Hash
                     value.deep_merge(res[key].to_h, options)
                  when OpenStruct
                     value.deep_merge(res[key].to_os, options)
                  when Array
                     value.concat([res[key]].compact.flatten(1))
                  when NilClass
                     res[key]
                  else
                     value_out =
                        if options[:mode] == :append
                           [res[key], value].compact.flatten(1)
                        elsif options[:mode] == :prepend
                           [value, res[key]].compact.flatten(1)
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
end
