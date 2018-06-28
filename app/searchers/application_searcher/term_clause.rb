class ApplicationSearcher
  class TermClause < Clause
    attr_reader :term

    def initialize operator, field, term
      super(operator, field)

      @term = term
    end

    def blank?
      term.blank?
    end
  end
end
