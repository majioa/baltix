class Baltix::Spec::Rpm::Name
   class InvalidAdoptedNameError < StandardError; end
   class UnsupportedMatchError < StandardError; end

   PREFICES = %w(gem ruby rubygem)
   RULE = /^(?<full_name>(?:(?<prefix>#{PREFICES.join('|')})-)?(?<name>.*?))(?:-(?<suffix>doc|devel))?$/

   attr_reader :name, :kind, :suffix
   attr_accessor :support_name

   def aliases
      @aliases ||= []
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

   def eql_by? value, other
      case value
      when :name
         ([ self.name, self.aliases ].flatten & [ other.name, other.aliases ].flatten).any?
      when :kind
         self.kind == other.kind
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
      %w(exec app).include?(kind) || %w(app).include?(support_name&.kind) ? nil : self.class.default_prefix
   end

   def autoname
      name&.downcase&.gsub(/[\._]/, "-")
   end

   def autosuffix
      %w(doc devel).include?(kind) && kind || nil
   end

   protected

   def initialize options = {}
      @aliases = options.fetch(:aliases, []) | options.fetch(:name, "").gsub(/[\.\_]+/, "-").split(",")
      @prefix = options[:prefix]
      @suffix = options[:suffix]
      @name = options[:name]
      @support_name = options[:support_name]
      @kind = options[:kind] && options[:kind].to_s ||
         @suffix ||
         @prefix && "lib" ||
         @support_name && "exec" || "app"
   end

   class << self
      def parse name_in, options_in = {}
         m, kind =
            if name_in.is_a?(self)
               [name_in.original_fullname.match(RULE), name_in.kind]
            else
               [name_in.match(RULE)]
            end

         aliases_in = (options_in[:aliases] || []).flatten.uniq
         subaliases = aliases_in - [ m["full_name"] ]
         #aliases = subaliases | [ m["full_name"] ]

         raise(InvalidAdoptedNameError) if !m

         prefixed = subaliases.size >= aliases_in.size
         options = {
            prefix: prefixed && m["prefix"] || nil,
            #prefix: subaliases.blank? && m["prefix"] || nil,
            #prefix: m["prefix"],
            suffix: m["suffix"],
            kind: kind,
            #name: m["name"],
            name: prefixed && m["name"] || m["full_name"],
            #name: subaliases.blank? && m["name"] || m["full_name"],
         }.merge(options_in).merge({
            aliases: subaliases | [ m["full_name"] ]
         })

         options[:name] = options[:name].blank? && options[:aliases].first || options[:name]
         #binding.pry if name_in =~ /ruby/

         new(options)
      end
   end
end
