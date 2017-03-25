require 'erb'

#
# Eql module renders ERB query templates and runs them
#
module Eql
  class << self
    #
    # Create new builder
    #
    # @param [String, nil] path template's root folder
    # @param [Object, nil] conn DB connection or cursor
    #
    def new(path = nil, conn = nil)
      Builder.new(path || config.path, conn)
    end

    #
    # Load a builder with template and params
    #
    # @param [String, Symbol] tmpl template's name
    # @param [Object, nil] params template's params
    #
    # @return [Eql::Builder]
    #
    def load(tmpl, params = nil)
      new.tap { |b| b.load(tmpl, params) }
    end

    #
    # Execute a builder with template and params
    #
    # @param [String, Symbol] tmpl template's name
    # @param [Object, nil] params template's params
    #
    # @return [Object] returns excution results
    #
    def execute(tmpl, params = nil)
      load(tmpl, params).execute
    end

    #
    # Load a builder with template content
    #
    # @param [String] erb template's content
    #
    # @return [Eql::Builder]
    #
    def template(erb)
      new.tap { |b| b.template(erb) }
    end

    #
    # @return [Eql::Config]
    #
    def config
      @config ||= Config.new
    end

    #
    # Setup
    #
    def configure
      yield(config)
    end

    #
    # @see Eql::AdapterFactory#redister_adapter
    #
    def register_adapter(key, klass)
      AdapterFactory.register_adapter(key, klass)
    end
  end
end

%w[
  version
  config
  proxy
  builder
  adapter_factory
  adapters/base
  adapters/active_record
].each { |f| require_relative "eql/#{f}" }

