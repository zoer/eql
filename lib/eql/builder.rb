module Eql
  #
  # Builder class builds ERB templates and interact with adapters to run it.
  #
  class Builder
    # @param [String] returns path to a root folder with templates
    attr_reader :path
    # @param [String] retruns DB connectionor a currsor
    attr_reader :conn

    #
    # @param [String] path path to a root folder with templates
    # @param [String] conn DB connection or a cursor
    #
    def initialize(path, conn)
      @path = path
      @conn = conn
    end

    #
    # Load query's template and params
    #
    # @param [String] name template's name
    # @param [Object] params query's params
    #
    def load(name = nil, params = nil)
      load_template(name) if name
      load_params(params) if params
    end

    #
    # Load template with given name
    #
    # @param [String, Symbol] name template's name
    #
    def load_template(name)
      @template_content = File.read(resolve_path(name))
    end

    #
    # Load query's params
    #
    # @param [Object] params
    #
    def load_params(params)
      @params = params
    end

    #
    # Set content template
    #
    # @param [String] raw template's content
    #
    def template(raw)
      @template_content = raw
    end

    #
    # Proxy's adapter
    #
    # @retrn [Eql::Adapters::Base]
    #
    def adapter
      @adapter ||= AdapterFactory.factory(conn).new(self)
    end

    #
    # Template's content
    #
    # @return [String]
    #
    def template_content
      @template_content.to_s
    end

    class H < Hash
      def name
        :h
      end
    end

    #
    # Render a template
    #
    # @return [String] returns rendered templated
    #
    def render
      ERB.new(template_content).result(proxy_class.new(self, @params).get_binding)
    end

    #
    # Proxy class for template
    #
    # @return [Eql::Proxy]
    #
    def proxy_class
      Eql::Proxy.generate(adapter)
    end

    #
    # File template to find
    #
    # @param [String, Symbol] file template's name
    #
    # @return [String] returns file path pattern
    #
    def template_path(file)
      File.join(@path.to_s, file.to_s) + adapter.extension
    end

    #
    # Resolve file's path
    #
    # @raise [RuntimeError] when can't wind a file
    #
    # @param [String] file template's name
    #
    # @return [String] returns template's path
    #
    def resolve_path(file)
      path = template_path(file)
      Dir.glob(path).first.tap do |f|
        raise "Unable to find query template with #{path.inspect} location" unless f
      end
    end

    def method_missing(name, *args, &block)
      adapter.send(name, *args, &block)
    end

    #
    # Execute template query
    #
    # @param [String, Symbol] tmpl template's name
    # @param [Object, nil] params o
    #
    # @return [Object] returns execution results
    #
    def execute(tmpl = nil, params = nil)
      load(tmpl, params)
      adapter.execute
    end

    #
    # Execute params with a query
    #
    # @param [Object] params
    #
    # @return [Object] returns execution results
    #
    def execute_params(params = nil)
      load_params(params)
      adapter.execute
    end

    #
    # Clone current builder
    #
    # @return [Eql::Builder]
    #
    def clone
      self.class.new(path, conn)
    end
  end
end
