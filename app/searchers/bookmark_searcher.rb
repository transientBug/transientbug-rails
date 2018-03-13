class BookmarkSearcher
  class QueryParser < Parslet::Parser
    rule(:eof) { any.absent? }

    rule(:operator) { (str("+") | str("-")).as(:operator) }

    rule(:space)  { match("\s").repeat(1) }
    rule(:quote) { str("\"") }
    rule(:colon) { str(":") }
    rule(:word) { match("[^\s\"]").repeat(1) }

    rule(:term) { (word >> colon).absent? >> word.as(:term) }

    rule(:phrase) do
      (quote >> (word >> space.maybe).as(:term).repeat >> quote.present?)
    end

    rule(:field) do
      word.as(:field) >> colon >> str("//").absent?
    end

    rule(:field_only_clause) { operator.maybe >> field >> space.maybe }
    rule(:field_term_clause) { operator.maybe >> field.maybe >> (phrase | term) }

    rule(:clause) { (field_only_clause | field_term_clause).as(:clause) }

    rule(:query) { (clause >> space.maybe).repeat.as(:query) }

    root(:query)
  end

  class QueryTransformer < Parslet::Transform
    rule(clause: subtree(:clause)) do
      operator = clause[:operator]&.to_s
      field = clause.dig(:field, :term)&.to_s

      terms = nil

      if clause[:phrase].present?
        terms = [] unless clause[:phrase].respond_to? :map
        terms ||= clause[:phrase]&.map { |p| p[:term].to_s }
      else
        terms = clause[:term].to_s
      end

      Clause.new operator, field, terms
    end

    rule(query: sequence(:clauses)) { Query.new(clauses) }
  end

  class Clause
    OP_MAP = {
      "+" => :must,
      "-" => :must_not,
      nil => :should
    }.freeze

    attr_accessor :operator, :field, :terms

    def initialize operator, field, terms
      @operator = OP_MAP[ operator ].tap do |op_symbol|
        fail ArgumentError, "Unknown operator: `#{ operator }'" unless op_symbol
      end

      @field = field&.to_sym

      @terms = Array(terms).reject(&:empty?).compact
    end

    def terms
      @terms.join " "
    end

    def phrase?
      @terms.length > 1
    end

    def term?
      ! phrase?
    end

    def empty?
      @terms.empty?
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
      @should_terms = normalize_terms @should_terms, fields
      @must_terms = normalize_terms @must_terms, fields
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
      return { exists: { field: @clause.field } } if @clause.empty?

      { term: { @clause.field => @clause.terms } }
    end
  end

  class TextHeuristics
    def initialize clause
      @clause = clause
    end

    def to_elasticsearch
      return { exists: { field: @clause.field } } if @clause.empty?

      type = @clause.phrase? ? :match_phrase : :match
      { type => { @clause.field => @clause.terms } }
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

  def query_search query
    query_ast = Query.new []

    begin
      parse_tree = QueryParser.new.parse query
      binding.pry
      query_ast = QueryTransformer.new.apply parse_tree
    rescue Parslet::ParseFailed => e
      Rails.logger.error e
    end

    query_ast.normalize USER_SEARCHABLE_FIELDS
    elasticsearch_query = ElasticsearchQuery.new FIELD_TO_TYPE, query_ast

    BookmarksIndex::Bookmark.query elasticsearch_query.to_elasticsearch
  end
end
