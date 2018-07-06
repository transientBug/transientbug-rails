class ApplicationSearcher
  include Enumerable

  class << self
    def operation name, title, **opts, &block
      operations[ name ] = { options: opts.merge( display_name: title ), block: block }
    end

    def type name, **opts
      types[ name ] = opts
    end

    def joiner name, title, **opts
      joiners[ name ] = opts.merge( display_name: title )
    end

    def field name, title, **opts
      fields[ name ] = opts.merge( display_name: title )
    end

    def default &block
      @defaulter = block
    end

    def default_query input
      @defaulter.call input
    end

    def operations
      @operations ||= ancestor_hash :operations
    end

    def types
      @types ||= ancestor_hash :types
    end

    def joiners
      @joiners ||= ancestor_hash :joiners
    end

    def fields
      @fields ||= ancestor_hash :fields
    end

    def operation_options
      operations.dup.transform_values do |i|
        i[:options].tap do |opts|
          opts[:parameters] ||= 1
        end
      end
    end

    def type_mappings
      fail NotImplementedError, "#type_mappings should return a hash"
    end

    def normalized_fields
      fields.each_with_object({}) do |(name, data), memo|
        field_type = type_mappings[ name ]

        available_operations = types[ field_type ][:supported_operations] - data.fetch(:exclude_operations, [])

        normalized_operations = available_operations.each_with_object({}) do |operation, ops_memo|
          ops_memo[ operation ] = operation_options[ operation ]
        end

        normalized_field_config = {
          operations: normalized_operations,
          default_operation: types[ field_type ].fetch(:default_operation, available_operations.first),
          type: field_type
        }.merge data.slice(:display_name, :description)

        memo[ name ] = normalized_field_config
      end
    end

    def normalized_config
      {
        operations: operation_options,
        joiners: joiners,
        fields: normalized_fields
      }
    end

    protected

    # Allow classes to inherit their ancestors fields, joiners, types and
    # operations. This allows for progressively building searchers up, such as
    # having an ElasticsearchSearcher that defines the operations to build ES
    # queries, a BookmarksSearcher that inherits those operations while
    # defining public user facing searchable fields, and an
    # Admin::BookmarksSearcher which defines additional fields that are
    # available within the admin panel
    def ancestor_hash func
      (ancestors - [self])
        .select { |i| i.ancestors.include? ApplicationSearcher }
        .inject({}) { |memo, i| memo.merge i.send func }
    end
  end

  def queries
    @queries ||= []
  end

  def compile _input
    fail NotImplementedError, "should convert the input query AST to a finished query"
  end

  def query input=nil, &_block
    return self unless input

    queries << compile(input)

    self
  end

  def results
    fail NotImplementedError, "#results should return an array like object that responds to #each"
  end

  def each
    return enum_for(:each) unless block_given?

    results.each do |result|
      yield result
    end
  end

  def blank_query?
    queries.empty?
  end
end
