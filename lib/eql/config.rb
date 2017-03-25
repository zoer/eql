module Eql
  #
  # Config class holds rendering settings
  #
  class Config
    # @param [String]
    attr_accessor :path
    # @param [Symbol]
    attr_accessor :adapter

    def initialize
      @adapter = :active_record
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
