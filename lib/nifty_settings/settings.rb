require 'pathname'
require 'yaml'
require 'erb'

module NiftySettings
  class Settings
    def initialize(hash = {})
      @hash = Hash.new { |h, k| h[k] = self.class.new }
      hash.each_pair { |k, v| self[k] = v }
    end

    def ==(other)
      self.to_s == other.to_s
    end

    def to_hash
      unpack_attr @hash
    end
    alias_method :to_h, :to_hash

    def to_ary
      self.to_hash.values
    end
    alias_method :to_a, :to_ary

    def to_str
      if self.nil?
        nil
      else
        self.to_hash
      end.to_s
    end
    alias_method :to_s, :to_str

    def []=(k, v)
      @hash[k.to_sym] = normalize_attr(v)
    end

    def [](k)
      @hash[k.to_sym]
    end

    def has?(key)
      @hash.has_key?(key.to_sym)
    end

    def fetch(key, default = nil)
      has?(key) ? self[key] : default
    end

    def empty?
      @hash.empty?
    end
    alias_method :nil?, :empty?

    def method_missing(name, *args, &block)
      name = name.to_s
      key, modifier = name[0..-2], name[-1, 1]
      case
      when modifier == '=' then self.send(:[]=, key, *args)
      when self.has?(name) then self[name]
      when modifier == '?' then self.has?(key)
      end
    end

    def respond_to?(name, include_all = false)
      true
    end

    class << self
      def load
        files = []

        settings_file = NiftySettings.configuration.settings_file || self.root.join('config', 'settings.yml')
        if File.file?(settings_file)
          files << settings_file
        end

        settings_dir = NiftySettings.configuration.settings_dir || self.root.join('config', 'settings')
        if File.directory?(settings_dir)
          files.concat Dir[File.join(settings_dir, '*.yml')]
        end

        return {} if files.empty?

        files.inject({}) do |hash, file|
          contents = File.read(file)
          contents = ERB.new(contents).result
          contents = YAML.load(contents) || {}
          if env
            contents = (contents['default'] || {}).deep_merge(contents[env] || {})
          end
          hash.deep_merge contents
        end
      end

      def default
        @@default ||= self.new(self.load)
      end

      def reset!
        @@default = nil
        default # Force us to reload the settings
        # If a setup block is defined, call it post configuration.
        true
      end

      def method_missing(name, *args, &block)
        default.send(name, *args, &block)
      end

      def respond_to?(name, include_all = false)
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
          value.each_pair { |k, v| h[k] = unpack_attr(v) }
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
        other_hash.each_pair do |k, v|
          tv = this_hash[k]
          this_hash[k] = case
          when tv.is_a?(Hash) && v.is_a?(Hash)
            tv.deep_merge(v, &block)
          when block_given? && tv
            block.call(k, tv, v)
          else
            v
          end
        end
      end
    end
  end
end
