class ApplicationSearcher
  class Query
    attr_reader :clauses, :should_terms, :must_terms, :must_not_terms

    def initialize clauses
      @clauses = clauses
      assign_groups clauses
    end

    # rubocop:disable Metrics/AbcSize
    def expand_and_alias search_keywords
      fields = search_keywords.keys
      alias_map = search_keywords.each_with_object({}) do |(field, aliases), memo|
        Array(aliases).each do |ali|
          memo[ ali ] = field
        end
      end

      grouped_expanded_clauses = @clauses.flat_map do |clause|
        next clause if clause.field && fields.include?(clause.field)

        if alias_map.key? clause.field
          next clause.dup.tap do |dup_clause|
            dup_clause.field = alias_map[ clause.field ]
          end
        end

        should_terms = fields.map do |field|
          clause.dup.tap do |dup_clause|
            dup_clause.field = field
            dup_clause.op = nil
            dup_clause.operator = :should
          end
        end

        NestedClause.new clause.op, should_terms
      end

      assign_groups grouped_expanded_clauses
    end
    # rubocop:enable Metrics/AbcSize

    def assign_groups ungrouped_clauses
      grouped = ungrouped_clauses.chunk(&:operator).to_h

      @should_terms   = grouped.fetch(:should, [])
      @must_terms     = grouped.fetch(:must, [])
      @must_not_terms = grouped.fetch(:must_not, [])
    end
  end
end
