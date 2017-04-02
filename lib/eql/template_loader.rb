module Eql
  #
  # Loader class loads templates and caches them.
  #
  class TemplateLoader
    extend Forwardable

    def_delegator 'self.class', :cache

    # @return [Eql::Builder]
    attr_reader :builder

    #
    # @param [Eql::Builder] builder
    #
    def initialize(builder)
      @builder = builder
    end

    #
    # Load builder template
    #
    # @param [String, Symbol] name template's name
    #
    # @return [String] returns loaded template
    #
    def load_template(name)
      path = resolve_path(name)
      return load_file(path) unless Eql.config.cache_templates?
      cache[path] ||= load_file(path)
    end

    #
    # Load file's content
    #
    # @api private
    #
    # @param [String] path file's path
    #
    # @return [String]
    #
    def load_file(path)
      File.read(path)
    end

    #
    # File template to find
    #
    # @api private
    #
    # @param [String, Symbol] file template's name
    #
    # @return [String] returns file path pattern
    #
    def template_path(file)
      [
        File.join(@builder.path.to_s, file.to_s),
        @builder.adapter.extension
      ].join
    end

    #
    # Resolve file's path
    #
    # @api private
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

    #
    # Templates cache
    #
    # @return [Hash{String => String}]
    #
    def self.cache
      @cache ||= {}
    end
  end
end
