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
    memo[ field ] = BookmarksIndex::Bookmark.mappings_hash[:bookmark][:properties][ field ][:type].to_sym
  end.freeze

  class QueryParser < Parslet::Parser
    rule(:operator) { (str("+") | str("-")).as(:operator) }

    rule(:space)  { match("\s").repeat(1) }
    rule(:quote) { str("\"") }
    rule(:colon) { str(":") }

    rule(:term) { match("[^\s\:\"]").repeat(1).as(:term) }

    rule(:phrase) do
      (quote >> (term >> space.maybe).repeat >> quote).as(:phrase)
    end

    rule(:field) do
      (term >> colon).as(:field)
    end

    rule(:clause) { (operator.maybe >> field.maybe >> (phrase | term) ).as(:clause) }

    rule(:query) { (clause >> space.maybe).repeat.as(:query) }

    root(:query)
  end

  class QueryTransformer < Parslet::Transform
    rule(clause: subtree(:clause)) do
      operator = clause[:operator]&.to_s
      field = clause.dig(:field, :term)&.to_s
      terms = nil

      klass = nil

      if clause[:term]
        terms = clause[:term].to_s
        klass = TermClause
      elsif clause[:phrase]
        terms = clause[:phrase].map { |p| p[:term].to_s }.join " "
        klass = PhraseClause
      else
        fail ArgumentError, "Unexpected clause type: `#{ clause }'"
      end

      klass.new operator, field, terms
    end

    rule(query: sequence(:terms)) { Query.new(terms) }
  end

  class Operator
    def self.symbol(str)
      case str
      when "+"
        :must
      when "-"
        :must_not
      when nil
        :should
      else
        fail ArgumentError, "Unknown operator: `#{ str }'"
      end
    end
  end

  class Clause
    attr_accessor :operator, :fields, :terms

    def initialize operator, fields, terms
      @operator = Operator.symbol operator

      if fields
      @fields   = Array(fields)
        .map(&:to_sym)
        .select { |field| USER_SEARCHABLE_FIELDS.include? field }
      else
        @fields ||= USER_SEARCHABLE_FIELDS
      end

      @terms    = terms
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

  attr_reader :query

  def initialize query
    @query = query
  end

  def to_elasticsearch
    parse_tree = QueryParser.new.parse query
    QueryTransformer.new.apply(parse_tree).to_elasticsearch
  end

  def search
    BookmarksIndex::Bookmark.query(to_elasticsearch)
  end
end
