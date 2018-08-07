module QueryGrammar
  class Compiler
    class Index
      class IndexDSL
        class OperatorDSL
          attr_reader :operator

          def self.build **opts, &block
            new(**opts).tap do |obj|
              obj.instance_eval(&block)
            end.operator
          end

          def initialize prefix, **opts
            @operator = {
              name: nil,
              description: nil,
              arity: nil,
              type: nil,
              compile: nil
            }.merge(opts)
          end

          def respond_to_missing? func, **args
            return true
          end

          def method_missing func, *args, **opts, &block
            @operator[ func ] = args.first || block
          end
        end

        def self.build &block
          new.tap do |obj|
            obj.instance_eval(&block)
          end.index
        end

        def index
          @index ||= Index.new
        end

        def type key, &block
          index.types[ key ] = block
        end

        def default *args
          args.each do |field|
            index.fields[ field.to_s ][:default] = true
          end
        end

        def operator prefix, **opts, &block
          index.operators[ prefix ] = OperatorDSL.build(**opts, &block)
        end

        def respond_to_missing? func, *args
          return true if index.types[ func ]

          super(func, *args)
        end

        def method_missing func, *args, **opts, &block
          if index.types[ func ]
            field = {
              aliases: (opts.delete(:aliases) || []).map(&:to_s),
              existable: false,
              sortable: false,
              default: false,
              type: func,
              compile: index.types[ func ]
            }.merge opts

            index.fields[ args.first.to_s ] = field

            return field
          end

          super(func, *args, **opts, &block)
        end
      end

      def self.build &block
        IndexDSL.build(&block)
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

    class ES < Compiler
      class << self
        attr_reader :index

        def define_index &block
          @index = Index.build(&block)
        end
      end

      def context
        @context ||= {
          query: {},
          sort: {}
        }
      end

      def compile ast
        result = ast.accept self
        context[:query] = result

        context
      end

      def index
        self.class.index
      end

      visit :group do |group|
        joiner = group.conjoiner == :or ? :should : :must
        inside = group.items.map { |i| i.accept self }.compact

        # todo: flatten, if there is a nested bool in `inside` then it should be
        # merged with this outer layer according to bool logic and precedence
        {
          bool: {
            joiner => inside
          }
        }
      end

      visit :negator do |negator|
        if negator.items.is_a?(Array)
          inside = negator.items.map { |i| i.accept self }.compact
        else
          inside = visit negator.items
        end

        {
          bool: {
            must_not: inside
          }
        }
      end

      visit :clause do |clause|
        if clause.prefix.blank?
          next {
            bool: {
              should: index.default_fields.map do |field|
                field_data = index.fields[ index.resolve_field field ]
                QueryGrammar::Cloaker.new(bind: self).cloak(clause, &field_data[:compile])
              end
            }
          }
        end

        if index.operators.key? clause.prefix
          handler = index.operators[ clause.prefix ]
          next QueryGrammar::Cloaker.new(bind: self).cloak(clause, &handler[:compile])
        end

        field_data = index.fields[ index.resolve_field clause.prefix ]
        throw "unable to search on non-existant field #{ field }" unless field_data

        QueryGrammar::Cloaker.new(bind: self).cloak(clause, &field_data[:compile])
      end
    end
  end
end
