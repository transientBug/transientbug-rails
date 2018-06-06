class ApplicationSearcher
  class PhraseClause < Clause
    attr_reader :phrase

    def initialize operator, field, phrase
      super(operator, field)

      @phrase = phrase
    end

    def blank?
      phrase.blank?
    end
  end
end
