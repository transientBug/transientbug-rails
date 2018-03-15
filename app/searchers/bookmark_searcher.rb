class BookmarkSearcher
  class QueryParser < Parslet::Parser
    rule(:eof) { any.absent? }

    rule(:operator) { (str("+") | str("-")).as(:operator) }

    rule(:space)  { match("\s").repeat(1) }
    rule(:quote) { str("\"") }
    rule(:colon) { str(":") }
    rule(:word) { match("[^\s\"]").repeat(1) }

    rule(:term) { word.as(:term) }

    rule(:phrase) do
      quote >> (word >> space.maybe).repeat.as(:phrase) >> quote
    end

    def self.fields *args
      args.each do |arg|
        rule("#{ arg }_field") { str(arg).as(:field) >> colon }
      end

      rule(:field) do
        first = send(:"#{ args.first }_field")
        args[1..-1].reduce(first) { |memo, arg| memo.| send(:"#{ arg }_field") }
      end
    end

    rule(:field_only_clause) { operator.maybe >> field >> (space | eof).present? }
    rule(:field_term_clause) { operator.maybe >> field.maybe >> (phrase | term) }

    rule(:clause) { (field_only_clause | field_term_clause).as(:clause) }

    rule(:query) { (clause >> space.maybe).repeat.as(:query) }

    root(:query)
  end

  class QueryTransformer < Parslet::Transform
    rule(clause: subtree(:clause)) do
      operator = clause[:operator]&.to_s
      field = clause[:field]&.to_s

      if clause[:phrase]
        PhraseClause.new operator, field, clause[:phrase]
      else
        TermClause.new operator, field, clause[:term]
      end
    end

    rule(query: sequence(:clauses)) { Query.new(clauses) }
  end

  class Clause
    OP_MAP = {
      "+" => :must,
      "-" => :must_not,
      nil => :should
    }.freeze

    attr_accessor :operator, :field, :term

    def initialize operator, field
      @operator = OP_MAP[ operator ].tap do |op_symbol|
        fail ArgumentError, "Unknown operator: `#{ operator }'" unless op_symbol
      end

      @field = field&.to_sym
    end

    def blank?
      fail NotImplementedError
    end
  end

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
      field_type = @mappings[ clause.field ]
      clause_heuristics = HEURISTICS_MAP[ field_type ].new clause
      clause_heuristics.to_elasticsearch
    end

    def to_elasticsearch
      bool = {}

      bool[:should]   = query.should_terms.flat_map(&method(:clause_to_query)) if query.should_terms.any?
      bool[:must]     = query.must_terms.flat_map(&method(:clause_to_query)) if query.must_terms.any?
      bool[:must_not] = query.must_not_terms.flat_map(&method(:clause_to_query)) if query.must_not_terms.any?

      { bool: bool }
    end
  end

  def search params
    query_search(params[:q])
  end

  private

  USER_SEARCHABLE_FIELDS = [
    :uri,
    :title,
    :description,
    :tags
  ].freeze

  FIELD_TO_TYPE = USER_SEARCHABLE_FIELDS.each_with_object({}) do |field, memo|
    properties = BookmarksIndex::Bookmark.mappings_hash[:bookmark][:properties]
    memo[ field ] = properties[ field ][:type].to_sym
  end.freeze

  class BookmarksQueryParser < QueryParser
    fields(*USER_SEARCHABLE_FIELDS)
  end

  def query_search query
    query_ast = Query.new []

    begin
      parse_tree = BookmarksQueryParser.new.parse query
      query_ast = QueryTransformer.new.apply parse_tree
      query_ast.normalize USER_SEARCHABLE_FIELDS
    rescue Parslet::ParseFailed => e
      Rails.logger.error e
    end

    elasticsearch_query = ElasticsearchQuery.new FIELD_TO_TYPE, query_ast

    BookmarksIndex::Bookmark.query elasticsearch_query.to_elasticsearch
  end
end
