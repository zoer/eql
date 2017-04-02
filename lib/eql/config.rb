module Eql
  #
  # Config class holds rendering settings
  #
  class Config
    # @return [String] returns default templates folder
    attr_accessor :path
    # @return [Symbol] returns key of default adapter
    attr_accessor :adapter
    attr_writer :cache_templates

    def initialize
      @adapter         = :active_record
      @cache_templates = true
    end

    #
    # Should templates be cached?
    #
    # @return [Boolean]
    #
    def cache_templates?
      @cache_templates
    end

    #
    # @return [String] returns templates root folder
    #
    def path
      @path ||= defined?(Rails) ? Rails.root : Dir.pwd
    end

    #
    # @return [Eql::Adapters::Base] returns default adapter
    #
    def default_adapter
      return unless adapter
      @default_adapter ||= AdapterFactory.adapters[adapter]
    end
  end
end
