class ApplicationSearcher
  class Query
    attr_accessor :should_terms, :must_not_terms, :must_terms

    def initialize clauses
      grouped = clauses.chunk { |c| c.operator }.to_h

      @should_terms   = grouped.fetch(:should, [])
      @must_terms     = grouped.fetch(:must, [])
      @must_not_terms = grouped.fetch(:must_not, [])
    end

    def normalize fields
      @should_terms   = normalize_terms @should_terms, fields
      @must_terms     = normalize_terms @must_terms, fields
      @must_not_terms = normalize_terms @must_not_terms, fields
    end

    private

    def normalize_terms terms, fields
      terms.flat_map do |clause|
        next clause if clause.field

        fields.map do |field|
          clause.dup.tap do |dup_clause|
            dup_clause.field = field
          end
        end
      end
    end
  end
end
