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
      type = index_klass.mappings_hash.values.first[:properties][ name ][:type].to_sym
      fields[ name ] = opts.merge( display_name: title, type: type )
    end

    def operations
      @operations ||= {}
    end

    def types
      @types ||= {}
    end

    def joiners
      @joiners ||= {}
    end

    def index_klass
      @index_klass ||= nil
    end

    def fields
      @fields ||= {}
    end

    def config
      ops = operations.transform_values { |i| i[:options] }

      {
        operations: ops,
        types: types,
        joiners: joiners
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
  end
end
