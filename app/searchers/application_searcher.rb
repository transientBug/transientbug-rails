class ApplicationSearcher
  include Enumerable
  include Concerns::ActiveRecord
  include Concerns::Pagination

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

    def index klass
      @index_klass = klass
    end

    def field name, title, **opts
      fields[ name ] = opts.merge( display_name: title )
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

    def index_klass
      @index_klass ||= nil
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
      index_klass.mappings_hash.values.first[:properties]
    end

    # rubocop:disable Metrics/AbcSize
    def normalized_fields
      fields.each_with_object({}) do |(name, data), memo|
        field_type = type_mappings[ name ][:type].to_sym

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
    # rubocop:enable Metrics/AbcSize

    def normalized_config
      {
        operations: operation_options,
        joiners: joiners,
        fields: normalized_fields
      }
    end

    protected

    def ancestor_hash func
      (ancestors - [self])
        .select { |i| i.ancestors.include? ApplicationSearcher }
        .inject({}) { |memo, i| memo.merge i.send func }
    end
  end

  def queries
    @queries ||= []
  end

  def chewy_modifiers
    @chewy_modifiers ||= []
  end

  def query input=nil, &block
    chewy_modifiers << block if block_given?

    return self unless input

    queries << compile(input)

    self
  end

  def compile query_ast
    bool = query_ast.slice(*self.class.joiners.keys).each_with_object({}) do |(joiner, values), memo|
      memo[ joiner ] = values.map do |value|
        next compile value unless value.key? :field

        self.class.operations[ value[:operation] ][:block].call value[:field], value[:values]
      end
    end

    {
      bool: bool
    }
  end

  def chewy_results
    @chewy_results ||= begin
      es_results = queries.inject(self.class.index_klass) { |memo, query| memo.query query }
      chewy_modifiers.reverse.inject(es_results) { |memo, modifier| modifier.call memo }
    end
  end

  def results
    @results ||= begin
      return fetch [] if blank_query?

      fetch chewy_results
    end
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
