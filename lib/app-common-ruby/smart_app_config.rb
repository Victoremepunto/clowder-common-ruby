require "ostruct"
require "json"

module AppCommonRuby
  class SmartAppConfig
    attr_reader :config

    def initialize
      @config = OpenStruct.new
    end

    def load_config(filename)
      return if filename.nil? || !File.exist?(filename)

      schema = File.read(filename)
      @config = JSON.parse(schema, object_class: OpenStruct)
      @definitions = @config.definitions
    end

    def create_types(filename)
      File.open(filename, 'a') do |f|
        f << "require 'ostruct'\n"
        @definitions.each_pair do |k, v|
          f << create_classes(k, v)
        end
      end
    end

    def create_classes(key, value)
      stream = StringIO.new

      stream << "\nclass #{key} < OpenStruct\n"
      stream << create_attributes(value)
      stream << create_hash_initialize_function(value)
      stream << "end\n"

      stream.string
    end

    def create_attributes(value)
      properties = value.properties
      value.required.each do |r|
        raise "#{r} is required" if properties.send(r).nil?
      end

      attributes = StringIO.new
      properties.each_pair do |k, v|
        attributes << "  attr_accessor :#{k}\n" if v.send(:type) == "array" || v.send('$ref')
      end
      attributes << "\n"

      attributes.string
    end

    def create_attribute_keys(value)
      properties = value.properties
      attribute_keys = StringIO.new
      attribute_keys << "\n  def valid_keys\n"
      attribute_keys << "    [].tap do |keys|\n"
      properties.each_pair do |k, v|
        attribute_keys << "      keys << :#{k}\n"
      end
      attribute_keys << "    end\n"
      attribute_keys << "  end\n"

      attribute_keys.string
    end

    def create_hash_initialize_function(value)
      init_function = StringIO.new
      init_function << "  def initialize(attributes)\n"
      init_function << "    super\n"
      init_function << "    raise 'The input argument (attributes) must be a hash' if (!attributes || !attributes.is_a?(Hash))\n"
      init_function << "\n"
      init_function << "    attributes = attributes.each_with_object({}) do |(k, v), h|\n"
      init_function << "      raise \"The input [\#{k}] is invalid\" unless valid_keys.include?(k.to_sym)\n"
      init_function << "      h[k.to_sym] = v\n"
      init_function << "    end\n"
      init_function << "\n"
      value.properties.each_pair do |k, v|
        if v.send(:type) == "array"
          empty = false
          klass = v.items.send("$ref").rpartition('/').last
          init_function << "    @#{k} = []\n"
          init_function << "    attributes.fetch(:#{k.to_sym}, []).each do |attr|\n"
          init_function << "      @#{k} << #{klass}.new(attr)\n"
          init_function << "    end\n"
        elsif v.send('$ref')
          empty = false
          klass = v.send('$ref').rpartition('/').last
          init_function << "    @#{k} = #{klass}.new(attributes.fetch(:#{k.to_sym}, {}))\n"
        end
      end
      init_function << "  end\n"
      init_function << create_attribute_keys(value)
      init_function.string
    end

    def snakecase(str)
      str.to_s.gsub(/(?<!^)[A-Z]/) { "_#{$&}" }.downcase
    end
  end
end
