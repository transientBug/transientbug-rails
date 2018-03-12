class BookmarkSearcher
  class QueryParser < Parslet::Parser
    rule(:eof) { any.absent? }

    rule(:operator) { (str("+") | str("-")).as(:operator) }

    rule(:space)  { match("\s").repeat(1) }
    rule(:quote) { str("\"") }
    rule(:colon) { str(":") }

    rule(:term) { match("[^\s\:\"]").repeat(1).as(:term) }

    rule(:phrase) do
      (quote >> (term >> space.maybe).repeat(0) >> quote).as(:phrase)
    end

    rule(:field) do
      (term >> colon).as(:field)
    end

    rule(:field_term_clause) { operator.maybe >> field.maybe >> (phrase | term) }
    rule(:field_only_clause) { operator.maybe >> field >> space.maybe }

    rule(:clause) { (field_term_clause | field_only_clause).as(:clause) }

    rule(:query) { ((clause >> space.maybe)).repeat.as(:query) }

    root(:query)
  end

  class QueryTransformer < Parslet::Transform
    rule(clause: subtree(:clause)) do
      operator = clause[:operator]&.to_s
      field = clause.dig(:field, :term)&.to_s

      terms = nil

      if clause[:phrase].present?
        terms = "" unless clause[:phrase].respond_to? :map
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

    attr_accessor :operator, :fields, :terms

    def initialize operator, fields, terms
      @operator = OP_MAP[ operator ].tap do |op_symbol|
        fail ArgumentError, "Unknown operator: `#{ operator }'" unless op_symbol
      end

      @fields = Array(fields).map(&:to_sym)

      @terms = terms
    end

    def phrase?
      terms.length > 1
    end

    def term?
      ! phrase?
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
  end

  class ElasticsearchQuery
    attr_reader :query

    TYPE_TO_QUERY = {
      nil: ->(field, clause) { { exists: { field: field } } },
      keyword: ->(field, clause) { { term: { field => clause.terms } } },
      text: lambda do |field, clause|
        type = clause.phrase? ? :match_phrase : :match
        { type => { field => clause.terms } }
      end
    }.freeze

    def self.builder_for field_to_type_map
      Class.new self do
        def field_to_type_mappings_hash
          field_to_type_map
        end
      end
    end

    def initialize query
      @query = query
    end

    def clause_to_query clause
      binding.pry
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

  ESQueryBuilder = ElasticsearchQuery.builder_for(FIELD_TO_TYPE)

  def query_search query
    parse_tree = QueryParser.new.parse query
    query = QueryTransformer.new.apply parse_tree
    elasticsearch_query = ESQueryBuilder.new(query).to_elasticsearch

    BookmarksIndex::Bookmark.query elasticsearch_query
  end
end
