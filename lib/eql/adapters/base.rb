module Eql
  #
  # Adapters module contains DB adapters
  #
  module Adapters
    #
    # Base class contains basic adapter logic
    #
    class Base
      module ContextHelpers
      end

      # @return [Eql::Builder]
      attr_reader :builder

      #
      # Does adapter match connection?
      #
      # @param [Object] conn
      #
      # @return [Boolean]
      #
      def self.match?(conn)
        raise NotImplementedError
      end

      #
      # @param [Eql::Builder] builder
      #
      def initialize(builder)
        @builder = builder
      end

      #
      # Execute adapter
      #
      # @return [Object] return exection results
      #
      def execute
        raise NotImplementedError
      end

      #
      # Get adapter's template extensions
      #
      # @return [String]
      #
      def extension
        '.erb'
      end
    end
  end
end
