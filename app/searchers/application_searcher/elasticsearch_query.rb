class ApplicationSearcher
  class KeywordHeuristics
    def initialize clause
      @clause = clause
    end

    def to_elasticsearch
      return { exists: { field: @clause.field } } if @clause.blank?

      return { term: { @clause.field => @clause.phrase.to_s } } if @clause.is_a? PhraseClause
      { term: { @clause.field => @clause.term.to_s } }
    end
  end

  class TextHeuristics
    def initialize clause
      @clause = clause
    end

    def to_elasticsearch
      return { exists: { field: @clause.field } } if @clause.blank?

      return { match_phrase: { @clause.field => @clause.phrase.to_s } } if @clause.is_a? PhraseClause
      { match: { @clause.field => @clause.term.to_s } }
    end
  end

  class ElasticsearchQuery
    attr_reader :query

    HEURISTICS_MAP = {
      text: TextHeuristics,
      keyword: KeywordHeuristics
    }.freeze

    def initialize field_mappings, query
      @mappings = field_mappings
      @query = query
    end

    def clause_to_query clause
      return self.class.new(@mappings, clause.query).to_elasticsearch if clause.is_a? NestedClause

      field_type = @mappings[ clause.field ]
      clause_heuristics = HEURISTICS_MAP[ field_type ].new clause
      clause_heuristics.to_elasticsearch
    end

    # rubocop:disable Metrics/AbcSize
    def to_elasticsearch
      bool = {}

      bool[:should]   = query.should_terms.flat_map(&method(:clause_to_query))   if query.should_terms.any?
      bool[:must]     = query.must_terms.flat_map(&method(:clause_to_query))     if query.must_terms.any?
      bool[:must_not] = query.must_not_terms.flat_map(&method(:clause_to_query)) if query.must_not_terms.any?

      { bool: bool }
    end
    # rubocop:enable Metrics/AbcSize
  end
end
