module Eql
  #
  # Proxy class proxies adapaters helpers and params to a template
  #
  class Proxy
    #
    # @param [Eql::Builder] builder
    # @param [Object] params template's params to proxy
    #
    def initialize(builder, params = nil)
      @builder = builder
      @params = params
      if @params.is_a?(Hash)
        @params = params.keys.each_with_object({}) do |key, ret|
          ret[key.respond_to?(:to_sym) ? key.to_sym : key] = params[key]
        end
      end
    end

    #
    # Render partial template
    #
    # @param [String] tmpl partial's name
    # @param [Object] params template's params
    #
    # @return [String] returns rendered template
    #
    def render(tmpl, params = nil)
      b = @builder.clone
      b.load(tmpl, params)
      b.render
    end

    def method_missing(name, *args, &block)
      return @params[name] if @params.is_a?(Hash) && @params.key?(name)
      @params.send(name, *args, &block)
    end

    def respond_to_missing?(name, *)
      @params.is_a?(Hash) && @params.key?(name) ||
        @params.respond_to?(name) ||
        super
    end

    #
    # Get proxy binding
    #
    # @return [Binding]
    #
    def get_binding
      # binding.name  # => :binding
      # if we have variable with the 'name' name we need to make a closure
      name = send(:name) if respond_to?(:name)
      binding
    end

    class << self
      #
      # Cached generated proxy classes
      #
      # @return [Hash{Symbol => Eql::Proxy}]
      #
      def generated
        @generated ||= {}
      end

      #
      # Generate a proxy class for given adapter
      #
      # @param [Eql::Adapters::Base] adapter
      #
      # @return [Eql::Proxy] returns generated class
      #
      def generate(adapter)
        generated[adapter.class] ||= begin
          helpers = AdapterFactory.adapter_helpers(adapter)
          Class.new(self) do
            helpers.each { |h| include h }
          end
        end
      end
    end
  end
end
