module Eql
  module Adapters
    #
    # ActiveRecord class is a ActiveRecord::Base adapter
    #
    class ActiveRecord < Base
      #
      # ContextHelpers module contains template's helpers
      #
      module ContextHelpers
        #
        # Quote string
        #
        # @param [String] val string to quote
        #
        # @return [String] returns safety quoted string
        #
        def quote(val)
          ::ActiveRecord::Base.connection.quote(val)
        end
      end

      #
      # @see Eql::Adapters::Base#match?
      #
      def self.match?(conn)
        defined?(::ActiveRecord::Base) &&
          conn.is_a?(::ActiveRecord::ConnectionAdapters::AbstractAdapter)
      end

      #
      # Get rendered SQL
      #
      # @return [Stirng]
      #
      def sql
        builder.render
      end

      #
      # @see Eql::Adapters::Base#extension
      #
      def extension
        '.{sql.erb,erb.sql}'
      end

      #
      # @see Eql::Adapters::Base#execute
      #
      def execute
        conn.execute(sql).to_a
      end

      #
      # Get DB connection to execute a query
      #
      # @return [ActiveRecord::ConnectionAdapters::AbstractAdapter]
      #
      def conn
        builder.conn || ::ActiveRecord::Base.connection
      end
    end
  end
end

Eql.register_adapter :active_record, Eql::Adapters::ActiveRecord
