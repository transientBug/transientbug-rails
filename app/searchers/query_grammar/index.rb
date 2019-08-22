module QueryGrammar
  class Index
    autoload :Dsl, "query_grammar/index/dsl"
    autoload :OperatorDsl, "query_grammar/index/operator_dsl"

    def self.build &block
      Dsl.build(&block)
    end

    def types
      @types ||= {}
    end

    def fields
      @fields ||= {}
    end

    def operators
      @operators ||= {}
    end

    def sortable_fields
      fields.map do |(field, data)|
        [ field, data[:aliases] ] if data[:sortable]
      end.flatten.compact
    end

    def existable_fields
      fields.map do |(field, data)|
        [ field, data[:aliases] ] if data[:existable]
      end.flatten.compact
    end

    def default_fields
      fields.map do |(field, data)|
        field if data[:default]
      end.flatten.compact
    end

    def aliases
      # alias => field
      fields.each_with_object({}) do |(field, data), memo|
        data[:aliases].each do |aliass|
          memo[ aliass ] = field
        end
      end
    end

    def resolve_field field_or_alias
      return field_or_alias unless aliases.key? field_or_alias
      aliases[ field_or_alias ]
    end
  end
end
