class ApplicationSearcher
  class NestedClause < Clause
    attr_reader :clauses

    def initialize operator, clauses
      super(operator, nil)

      @clauses = clauses
    end

    def query
      @query ||= Query.new clauses
    end
  end
end
