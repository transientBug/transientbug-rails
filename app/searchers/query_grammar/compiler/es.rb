module QueryGrammar
  class Compiler
    class ES < Compiler
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

      visit :negator do |negator|
        inside = Array(negator.items).map { |i| i.accept self }.compact

        {
          bool: {
            must_not: inside
          }
        }
      end

      visit :group do |group|
        joiner = group.conjoiner == :or ? :should : :must
        inside = group.items.map { |i| i.accept self }.compact

        {
          bool: {
            joiner => inside
          }
        }
      end

      visit :sort_clause do |clause|
        context[:sort][ clause.field ] = { order: clause.direction }

        nil
      end

      visit :match_clause do |clause|
        type = clause.value.index(" ") ? :match_phrase : :match

        { type => { clause.field => clause.value } }
      end

      visit :equal_clause do |clause|
        { term: { clause.field => clause.value } }
      end

      visit :gt_range_clause do |clause|
        { range: { clause.field => { gt: clause.value } } }
      end

      visit :lt_range_clause do |clause|
        { range: { clause.field => { lt: clause.value } } }
      end

      visit :range_clause do |clause|
        { range: { clause.field => { gte: clause.low, lte: clause.high } } }
      end

      visit :exist_clause do |clause|
        { exists: { field: clause.field } }
      end
    end
  end
end
