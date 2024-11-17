module Lib
   class InvalidObjectMatchError < StandardError; end

   def space
      @space ||= cli.space
   end

   def cli
      @cli ||= Baltix::CLI.new
      @cli.option_parser.default_argv << '--verbose=info'
      @cli
   end

   def name_list
      @name_list ||= []
   end

   def names
      @names ||= []
   end

   def adopt_value value
      case value
      when ""
         nil
      when /{.*}/
         Baltix.load(value).to_os
      when /(\[|\|---)/
         Baltix.load(value)
      when /^:/
         value[1..-1].to_sym
      when /:/
         value.split(",").map {|v| v.split(":") }.to_os
      when /.yaml$/
         Baltix.load(IO.read(value))
      else
         value
      end
   end

   def error object, real, path = [], exception: true
      text = "Invalid object match #{object} at path '#{path.join('.')}', got #{real}"

      if exception
         Kernel.puts(text)
         raise InvalidObjectMatchError.new(text)
      end

      false
   end

   def deep_match obj, to_obj, path = [], exception: true
      case to_obj
      when Array
         array_match(obj, to_obj, path, exception:)
      when Hash, OpenStruct
         hash_match(obj, to_obj, path, exception:)
      when String
         return error(to_obj, obj, path, exception:) if obj.to_s != to_obj
      when Integer
         return error(to_obj, obj, path, exception:) if obj.to_i != to_obj
      else
         return error(to_obj, obj, path, exception:) if obj.class != to_obj.class || obj != to_obj
      end

      true
   end

   def array_match array_in, to_array, path, exception: true
      array = array_in.dup

      error(to_array, array, path, exception: exception) if [array, to_array].any? {|x| !x.class.ancestors.include?(Enumerable) }

      to_array.map.with_index do |to_val, index|
         idx =
            array.index do |val|
               deep_match(val, to_val, path | [index], exception: exception)
            end

         idx ? array.to_a.delete_at(idx) : error(to_val, array[index], path | [index], exception: exception)
      end.any?
   end

   def hash_match hash, to_hash, path, exception: true
      error(to_hash, hash, path, exception: exception) if [hash, to_hash].any? {|x| !(x.class.ancestors & [Hash, OpenStruct]).any? }

      to_hash.map do |(to_key, to_val)|
         value = hash.respond_to?(to_key) ? hash.send(to_key) : hash[to_key]

         deep_match(value, to_val, path | [to_key], exception: exception)
      end.any?
   end

   def space_value_for property_path
      property_path.split(".").reduce(space) do |object, sub|
         sub =~ /^\d+$/ && object[sub.to_i] || object.respond_to?(sub) && object.send(sub) || nil
      end
   end
end

World(Lib)
