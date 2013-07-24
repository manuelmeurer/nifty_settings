require 'pathname'
require 'yaml'
require 'erb'

module NiftySettings
  class Settings
    def initialize(hash = {})
      @hash = Hash.new { |h,k| h[k] = self.class.new }
      hash.each_pair { |k, v| self[k] = v }
    end

    def to_hash
      unpack_attr @hash
    end

    def []=(k, v)
      @hash[k.to_sym] = normalize_attr(v)
    end

    def [](k)
      @hash[k.to_sym]
    end

    def has?(key)
      key = key.to_sym
      @hash.has_key?(key) && @hash[key].present?
    end

    def fetch(key, default = nil)
      has?(key) ? self[key] : default
    end

    def blank?
      @hash.blank?
    end

    def present?
      !blank?
    end

    def method_missing(name, *args, &blk)
      name = name.to_s
      key, modifier = name[0..-2], name[-1, 1]
      case modifier
      when '?'
        has?(key)
      when '='
        send(:[]=, key, *args)
      else
        self[name]
      end
    end

    def respond_to?(name, key = false)
      true
    end

    class << self
      def setup(value = nil, &blk)
        @@setup_callback = (blk || value)
      end

      def settings_path
        @@settings_path ||= root.join('config', 'settings.yml').to_s
      end

      def load_from_file
        if !File.readable?(settings_path)
          $stderr.puts "Unable to load settings from #{settings_path} - Please check it exists and is readable."
          return {}
        end
        if env.nil?
          $stderr.puts 'Could not determine environment. If not using Rails, please set RACK_ENV env variable.'
          return {}
        end
        # Otherwise, try loading...
        contents = File.read(settings_path)
        contents = ERB.new(contents).result
        contents = YAML.load(contents)
        (contents['default'] || {}).deep_merge(contents[env] || {})
      end

      def default
        @@default ||= new(load_from_file)
      end

      def reset!
        @@default = nil
        default # Force us to reload the settings
        # If a setup block is defined, call it post configuration.
        @setup_callback.call if defined?(@setup_callback) && @setup_callback
        true
      end

      def method_missing(name, *args, &blk)
        default.send(name, *args, &blk)
      end

      def respond_to?(name, key = false)
        true
      end

      def root
        @root ||= defined?(Rails) ? Rails.root : Pathname.new(File.expand_path('.'))
      end

      def env
        @env ||= defined?(Rails) ? Rails.env : ENV['RACK_ENV']
      end
    end

    private

    def normalize_attr(value)
      case value
      when Hash
        self.class.new(value)
      when Array
        value.map { |v| normalize_attr(v) }
      else
        value
      end
    end

    def unpack_attr(value)
      case value
      when self.class
        value.to_hash
      when Hash
        Hash.new.tap do |h|
          value.each_pair { |k,v| h[k] = unpack_attr(v) }
        end
      when Array
        value.map { |v| unpack_attr(v) }
      else
        value
      end
    end
  end
end

# From activesupport/lib/active_support/core_ext/hash/deep_merge.rb
unless Hash.new.respond_to?(:deep_merge)
  class Hash
    def deep_merge(other_hash, &block)
      self.dup.tap do |this_hash|
        other_hash.each_pair do |k,v|
          tv = this_hash[k]
          if tv.is_a?(Hash) && v.is_a?(Hash)
            this_hash[k] = tv.deep_merge(v, &block)
          else
            this_hash[k] = block && tv ? block.call(k, tv, v) : v
          end
        end
      end
    end
  end
end
