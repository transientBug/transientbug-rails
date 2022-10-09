# frozen_string_literal: true

module QueryGrammar
  class Compiler
    # Converts a given query into an ActiveRecord Arel query
    class Arel < Compiler
      def initialize model
        super()

        @model = model
        @arel_table = model.arel_table
      end

      def context
        @context ||= {
          query: {},
          order: {},
        }
      end

      def compile ast
        context[:query] = ast.accept self

        context
      end

      visit :negator do |negator|
        inside = Array(negator.items).map { |i| i.accept self }.compact
        # puts "================================================================="
        # pp negator
        # puts "------------------"
        # pp inside
        # pp inside.any?

        case inside
        in []
          nil
        in [only]
          only.not
        in [first, *parts]
          parts.reduce(first) do |memo, part|
            memo.and part
          end
        end

        # {
          # bool: {
            # must_not: inside,
          # },
        # }
      end

      visit :group do |group|
        inside = group.items.map { |i| i.accept self }.compact
        # puts "================================================================="
        # pp group
        # puts "------------------"
        # pp inside
        # pp inside.any?

        case inside
        in []
          nil
        in [only]
          only
        in [first, *parts]
          parts.reduce(first) do |memo, part|
            memo.send group.joiner, part
          end
        end

        # {
          # bool: {
            # joiner => inside,
          # },
        # }
      end

      visit :sort_clause do |clause|
        context[:order][ clause.field ] = clause.direction

        nil
      end

      visit :match_clause do |clause|
        # debugger
        # type = clause.value.index(" ") ? :match_phrase : :match

        # { type => { clause.field => clause.value } }
        # TODO: ts_vector this shit up
        # @arel_table[clause.field].eq(clause.value)

        field = clause.field
        field = :search_title if field == :title

        quoted = ::Arel::Nodes.build_quoted(clause.value)
        tsquery = ::Arel::Nodes::NamedFunction.new("websearch_to_tsquery", [quoted])

        ::Arel::Nodes::InfixOperation.new("@@", @arel_table[field], tsquery)

        # TODO: Add in an option for the field to specify if it should also
        # include matches from the most similar word in the existing set of
        # bookmarks or not
      end

      visit :equal_clause do |clause|
        # { term: { clause.field => clause.value } }
        @arel_table[clause.field].eq(clause.value)
      end

      visit :gt_range_clause do |clause|
        # { range: { clause.field => { gt: clause.value } } }
        @arel_table[clause.field].gt(clause.value)
      end

      visit :lt_range_clause do |clause|
        # { range: { clause.field => { lt: clause.value } } }
        @arel_table[clause.field].lt(clause.value)
      end

      visit :range_clause do |clause|
        # { range: { clause.field => { gte: clause.low, lte: clause.high } } }
        @arel_table[clause.field].lteq(clause.value).and(@arel_table[clause.field].gteq(clause.value))
      end

      visit :exist_clause do |clause|
        # { exists: { field: clause.field } }
        # debugger
        return @model.reflections["tags"].klass.arel_table[:id].not_eq(nil) if @model.reflections.key? clause.field

        @arel_table[clause.field].not_eq(nil)
      end
    end
  end
end
