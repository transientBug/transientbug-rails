class ApplicationSearcher
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

    def build query_ast
      bool = query_ast.slice(*joiners.keys).each_with_object({}) do |(joiner, values), memo|
        memo[ joiner ] = values.map do |value|
          unless value.key? :field
            next build value
          end

          operations[ value[:operation] ][:block].call value[:field], value[:values]
        end
      end

      {
        bool: bool
      }
    end

    protected

    def ancestor_hash func
      (ancestors - [self])
        .select { |i| i.ancestors.include? ApplicationSearcher }
        .inject({}) { |memo, i| memo.merge i.send func }
    end
  end
end
