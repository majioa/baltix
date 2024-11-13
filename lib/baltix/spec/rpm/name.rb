class Baltix::Spec::Rpm::Name
   class InvalidAdoptedNameError < StandardError; end
   class UnsupportedMatchError < StandardError; end

   PREFICES = %w(gem ruby rubygem)
   RULE = /^(?<full_name>(?:(?<prefix>#{PREFICES.join('|')})-)?(?<name>.*?))(?:-(?<suffix>doc|devel))?$/
   LIB_RULE = /^(?<full_name>(?<name>.*?))(?:-(?<suffix>doc|devel))?$/

   attr_reader :name, :kind, :suffix, :options
   attr_accessor :support_name

   def approximate_kind
      @approximate_kind ||= alias_map.map {|x,y| [x,y.size]}.select {|x,_| x}.sort_by {|_,y| y}.last.first
   end

   def alias_map
      @alias_map ||= {}
   end

   def aliases
      #alias_map.values.flatten(1).uniq
      #TODO validate if it is really needed merge with support_name
      alias_map.values.flatten(1).uniq | (support_name&.aliases || [])
   end

   def prefix
      @prefix ||= kind == "lib" && self.class.default_prefix || nil
   end

   def self.default_prefix
      "gem"
   end

   def support_name= value
      case @support_name = value
      when NilClass
         @kind = kind == "exec" && "app" || @kind
      else
         @kind = kind == "app" && "exec" || @kind
      end
   end

   def eql? other, deep = false
      case other
      when self.class
         self.eql_by?(:kind, other) && self.eql_by?(:name, other)
      when String, Symbol
         (([ autoname, fullname ] | [ aliases ].flatten) & self.class.parse(other).aliases).any?
      else
         other.to_s == self.fullname
      end || deep && self.eql_by?(:support_name, other)
   end

   def == other
      eql?(other)
   end

   def === other
      eql?(other)
   end

   def =~ re
      to_s =~ re
   end

   def to_s
      fullname
   end

   def merge other
      options =
         %w(prefix suffix name support_name kind).map do |prop|
            [ prop.to_sym, other.send(prop) || self.send(prop) ]
         end.to_h

      self.class.new(options.merge(aliases: self.aliases | other.aliases))
   end

   def as kind
      return self.dup if kind == self.kind

      options_in = options.merge(kind: kind)
      aliases = alias_for(kind)

      options_in[:name] = aliases.sort_by {|x| x.size }.first unless aliases.blank?

      self.class.new(options_in)
   end

   def alias_for kind
      alias_map[kind] || []
   end

   def eql_by? value, other_in
      other = other_in.is_a?(String) ? self.class.parse(other_in) : other_in

      case value
      when :name
         ((alias_for(self.kind) | alias_for(nil)) &
            (other.alias_for(other.kind) | other.alias_for(nil))).any?
      when :kind
         !self.kind || !other.kind || self.kind == other.kind
      when :alias
         (self.aliases & other.aliases).any?
      when :support_name
         self.support_name === (other.is_a?(self.class) && other.support_name || other)
      else
         raise(UnsupportedMatchError.new)
      end
   end

   # +fullname+ returns newly reconstructed adopted full name based on the storen data.
   # All the "." and "_" is replaced with "-", and "ruby" prefix with "gem".
   #
   # name.fullname #=> "gem-foo-bar-baz-doc"
   #
   def fullname
      [ autoprefix, autoname, autosuffix ].compact.join("-")
   end

   def original_fullname
      [ prefix, name, suffix ].compact.join("-")
   end

   def autoprefix
      %w(doc lib devel).include?(kind) && !%w(app).include?(support_name&.kind) ? self.class.default_prefix : nil
   end

   def autoname n = name
      n&.downcase&.gsub(/[\._]/, "-")
   end

   def autosuffix
      %w(doc devel).include?(kind) && kind || nil
   end

   protected

   def alias_assign options
      name_in = alias_for(nil)
      kind_names =
         case kind
         when "doc", "devel"
            name_in.map { |x| [prefix, x, kind].compact.join("-") }
         when "lib"
            name_in.map { |x| [prefix || default_prefix, autoname(x)].join("-") }
         when "exec", "app"
            name_in
         else
            []
         end

      alias_map[kind] = alias_for(kind) ? alias_for(kind) | kind_names : kind_names
   end

   def kind_from_prefix
      PREFICES.include?(@prefix) ? "lib" : nil
   end

   def initialize options_in = {}
      options = self.class.parse_options(options_in[:name], options_in)

      @alias_map = options[:alias_map]
      @prefix = options[:prefix]
      @suffix = options[:suffix]
      @name = options[:name]
      @support_name = options[:support_name]
      @kind = options[:kind] ? options[:kind].to_s : self.kind_from_prefix
      @options = options.freeze
      self.alias_assign(options)
   end

   class << self
      def parse_options name_in, options_in = {}
         fullname, kind =
            if name_in.is_a?(self)
               m = name_in.name.match(RULE)

               [m.named_captures["full_name"], name_in.kind ? name_in.kind.to_s : nil]
            elsif name_in.nil?
               m = {}

               [nil]
            else
               m = name_in.match(RULE)

               [name_in]
            end

         kinds = [m["suffix"] || m["prefix"] && "lib" || ["exec", "app"]].flatten
         name_in = [m["name"], m["name"]&.gsub(/[\-\._]+/, "-")].uniq
         alias_hash =
            kinds.reduce({ nil => [options_in[:aliases], fullname].flatten.compact }) do |a, kind_in|
               a.merge({kind_in.to_s => name_in})
            end

         options = {
            kind: kind,
            name: fullname,
         }.merge(options_in.dup).merge({
            alias_map: alias_hash.merge((options_in[:alias_map] || {}).dup)
         })
      end

      def parse name_in, options_in = {}
         options = parse_options(name_in, options_in)

         options[:name] = options[:name].blank? ? (options[:aliases] || []).first : options[:name]

         new(options)
      end
   end
end
