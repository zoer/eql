module Eql
  #
  # AdapterFactory class detects adapters and their helpers
  #
  class AdapterFactory
    class << self
      # @return [Symbol]
      HELPERS_MODULE_NAME = :ContextHelpers

      #
      # Registered adapters
      #
      # @return [Hash{Symbol => Eql::Adapters::Base}]
      #
      def adapters
        @adapters ||= {}
      end

      #
      # Register a new adapter
      #
      # @param [Symbol] key adapter's key
      # @param [Eql::Adapters::Base] klass adapter's class
      #
      def register_adapter(key, klass)
        adapters[key] = klass
      end

      #
      # Get adapter's helper modules
      #
      # @param [Eql::Adapters::Base] adapter
      #
      # @return [Array<Module>]
      #
      def adapter_helpers(adapter)
        adapter.class.ancestors.each_with_object([]) do |klass, ret|
          next unless klass.is_a?(Class)
          next unless klass.const_defined?(HELPERS_MODULE_NAME)
          ret.unshift klass.const_get(HELPERS_MODULE_NAME)
        end
      end

      #
      # Detect adapter class
      #
      # @raise [RuntimeError] when can't find adapter's class
      #
      # @param [Object, nil] conn DB connection or a cursor
      #
      # @return [Eql::Adapters::Base]
      #
      def factory(conn)
        return Eql.config.default_adapter unless conn
        adapters.values.find { |a| a.match?(conn) if a.respond_to?(:match?) }.tap do |adapter|
          raise "Unable to detect adapter for #{conn.inspect}" unless adapter
        end
      end
    end
  end
end
