class BookmarkSearcher
  USER_SEARCHABLE_FIELDS = [
    :uri,
    :title,
    :description,
    :tags
  ].freeze

  TYPE_TO_QUERY = {
    keyword: ->(field, clause) { { term: { field => clause.terms } } },
    text: lambda do |field, clause|
      type = clause.is_a?(PhraseClause) ? :match_phrase : :match
      { type => { field => clause.terms } }
    end,
  }.freeze

  FIELD_TO_TYPE = USER_SEARCHABLE_FIELDS.each_with_object({}) do |field, memo|
    properties = BookmarksIndex::Bookmark.mappings_hash[:bookmark][:properties]
    memo[ field ] = properties[ field ][:type].to_sym
  end.freeze

  OP_MAP = {
    "+" => :must,
    "-" => :must_not,
    nil => :should
  }.freeze

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
      klass = nil

      if clause[:phrase].present?
        terms = "" unless clause[:phrase].respond_to? :map
        terms ||= clause[:phrase]&.map { |p| p[:term].to_s }&.join " "
        klass = PhraseClause
      else
        terms = clause[:term].to_s
        klass = TermClause
      end

      klass.new operator, field, terms
    end

    rule(query: sequence(:clauses)) { Query.new(clauses) }
  end

  class Clause
    attr_accessor :operator, :fields, :terms

    def initialize operator, fields, terms
      @operator = OP_MAP[ operator ].tap do |op_symbol|
        fail ArgumentError, "Unknown operator: `#{ operator }'" unless op_symbol
      end

      if fields
        @fields = Array(fields).map(&:to_sym)
          .select { |field| USER_SEARCHABLE_FIELDS.include? field }
      else
        @fields ||= USER_SEARCHABLE_FIELDS
      end

      @terms = terms
    end
  end

  class TermClause < Clause; end
  class PhraseClause < Clause; end

  class Query
    attr_accessor :should_terms, :must_not_terms, :must_terms

    def initialize clauses
      grouped = clauses.chunk { |c| c.operator }.to_h

      @should_terms   = grouped.fetch(:should, [])
      @must_terms     = grouped.fetch(:must, [])
      @must_not_terms = grouped.fetch(:must_not, [])
    end

    def clause_to_query clause
      clause.fields.flat_map do |field|
        TYPE_TO_QUERY[ FIELD_TO_TYPE[ field ] ].call field, clause
      end
    end

    def to_elasticsearch
      bool = {}

      bool[:should]   = should_terms.flat_map(&method(:clause_to_query)) if should_terms.any?
      bool[:must]     = must_terms.flat_map(&method(:clause_to_query)) if must_terms.any?
      bool[:must_not] = must_not_terms.flat_map(&method(:clause_to_query)) if must_not_terms.any?

      { bool: bool }
    end
  end

  def search params
    query_search(params[:q])
  end

  private

  def query_search query
    parse_tree = QueryParser.new.parse query
    query = QueryTransformer.new.apply parse_tree

    BookmarksIndex::Bookmark.query query.to_elasticsearch
  end
end
