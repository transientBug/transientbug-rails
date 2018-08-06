module QueryGrammar
  class Compiler
    class Index
      def fields
        @fields ||= {}
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

    class IndexDSL
      def self.build &block
        new.tap do |obj|
          obj.instance_eval(&block)
        end.index
      end

      def index
        @index ||= Index.new
      end

      def types
        @types ||= {}
      end

      def type key, **opts
        types[ key ] = opts
      end

      def default *args
        args.each do |field|
          index.fields[ field.to_s ][:default] = true
        end
      end

      def respond_to_missing? func, *args
        return true if types[ func ]

        super(func, *args)
      end

      def method_missing func, *args, **opts, &block
        if types[ func ]
          field = {
            aliases: (opts.delete(:aliases) || []).map(&:to_s),
            type: func,
            existable: false,
            sortable: false,
            default: false
          }.merge opts

          index.fields[ args.first.to_s ] = field

          return field
        end

        super(func, *args, **opts, &block)
      end
    end

    class ClauseDSL
      attr_reader :clause

      def self.build **opts, &block
        new(**opts).tap do |obj|
          obj.instance_eval(&block)
        end.clause
      end

      def initialize prefix:, **opts
        @clause = {
          prefix: prefix.to_s,
          name: nil,
          description: nil,
          arity: nil,
          input_format: nil,
          compile: nil
        }.merge(opts)
      end

      def respond_to_missing? func, **args
        return true
      end

      def method_missing func, *args, **opts, &block
        @clause[ func ] = args.first || block
      end
    end

    class ES < Compiler
      attr_reader :context

      class << self
        attr_reader :index, :clause_handlers

        def define_index &block
          @index = IndexDSL.build(&block)
        end

        def clause **opts, &block
          (@clause_handlers ||= []) << ClauseDSL.build(**opts, &block)
        end
      end

      def initialize
        @context = {
          query: {},
          sort: {}
        }
      end

      def compile ast
        result = visit ast
        context[:query] = result

        context
      end

      def index
        self.class.index
      end

      def clause_handlers
        self.class.clause_handlers
      end

      def handles_clause? clause
        clause_handlers.any? { |handler| handler[:prefix] == clause.prefix }
      end

      def handle_clause clause
        handler = clause_handlers.find { |clause_handler| clause_handler[:prefix] == clause.prefix }
        QueryGrammar::Compiler::Cloaker.new(bind: self).cloak(clause, &handler[:compile])
      end

      def operation_for field, values
        field_data = index.fields[ index.resolve_field field ]

        throw "unable to search on non-existant field #{ field }" unless field_data

        case field_data[:type]
        when :text
          return {
            bool: {
              must: values.map do |value|
                next {
                  match_phrase: { field => value }
                } if value.index(" ")

                {
                  match: { field => value }
                }
              end
            }
          } if values.is_a? Array

          return {
            match_phrase: { field => values }
          } if values.index(" ")

          {
            match: { field => values }
          }
        when :keyword
          return {
            terms: { field => values }
          } if values.is_a? Array

          {
            term: { field => values }
          }
        when :date
          return {
            bool: {
              must: values.map do |value|
                { term: { field => value } }
              end
            }
          } if values.is_a? Array

          {
            term: { field => values }
          }
        else throw "unknown type #{ field_data[:type] }"
        end
      end

      visit QueryGrammar::AST::Group do |group|
        joiner = group.conjoiner == :or ? :should : :must
        inside = group.items.map { |i| visit i }.compact

        # todo: flatten, if there is a nested bool in `inside` then it should be
        # merged with this outer layer according to bool logic and precedence
        {
          bool: {
            joiner => inside
          }
        }
      end

      visit QueryGrammar::AST::Negator do |negator|
        if negator.items.is_a?(Array)
          inside = negator.items.map { |i| visit i }.compact
        else
          inside = visit negator.items
        end

        {
          bool: {
            must_not: inside
          }
        }
      end

      visit QueryGrammar::AST::Clause do |clause|
        if clause.prefix.blank?
          next {
            bool: {
              should: index.default_fields.map do |field|
                operation_for field, clause.value
              end
            }
          }
        elsif handles_clause? clause
          next handle_clause clause
        end

        operation_for clause.prefix, clause.value
      end
    end
  end
end
