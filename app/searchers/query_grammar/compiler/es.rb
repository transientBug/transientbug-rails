module QueryGrammar
  class Compiler
    class ES < Compiler
      class << self
        attr_reader :index

        def define_index &block
          @index = QueryGrammar::Index.build(&block)
        end
      end

      def index
        self.class.index
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

      protected

      def cloak_compile clause, field=nil
        field = index.resolve_field(field || clause.prefix)
        field_data = index.fields[ field ]
        fail "unable to search on non-existant field #{ field }" unless field_data

        QueryGrammar::Cloaker.new(bind: self).cloak(clause.unary, field, clause.values, &field_data[:compile])
      end

      visit :group do |group|
        joiner = group.conjoiner == :or ? :should : :must
        inside = group.items.map { |i| i.accept self }.compact

        # TODO: flatten, if there is a nested bool in `inside` then it should be
        # merged with this outer layer according to bool logic and precedence
        {
          bool: {
            joiner => inside
          }
        }
      end

      visit :negator do |negator|
        inside = Array(negator.items).map { |i| i.accept self }.compact

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
                cloak_compile clause, field
              end
            }
          }
        end

        if index.operators.key? clause.prefix
          handler = index.operators[ clause.prefix ]
          next QueryGrammar::Cloaker.new(bind: self).cloak(clause, &handler[:compile])
        end

        cloak_compile clause
      end
    end
  end
end
