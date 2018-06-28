class ApplicationSearcher
  include Enumerable
  include Concerns::ActiveRecord
  include Concerns::Pagination

  UNBALANCED_QUOTES_ERROR = "Quotation marks were unbalanced, an extra quote was added to the end of the query".freeze

  class << self
    attr_reader :index_klass

    def index klass
      @index_klass = klass
    end

    def keyword field_name, aliases: nil
      search_keywords[ field_name ] = aliases

      parser_field_data = [ field_name, aliases ].flatten.compact
      parser_klass.fields(*parser_field_data)
    end

    def parser_klass
      @parser_klass ||= Class.new ApplicationSearcher::BaseQueryParser
    end

    def search_keywords
      @search_keywords ||= {}
    end

    def keywords
      @keywords ||= search_keywords.to_a.flatten.compact
    end

    def fields
      @fields ||= search_keywords.keys
    end

    def field_type_mappings
      @field_type_mappings ||= begin
        properties = index_klass.mappings_hash[:bookmark][:properties]

        fields.each_with_object({}) do |field, memo|
          memo[ field ] = properties[ field ][:type].to_sym
        end
      end
    end
  end

  attr_reader :input

  def errors
    @errors ||= Errors.new
  end

  def queries
    @queries ||= []
  end

  def chewy_modifiers
    @chewy_modifiers ||= []
  end

  def query str=nil, &block
    chewy_modifiers << block if block_given?

    queries << str if str.is_a? Hash
    queries.concat str if str.is_a? Array

    return self unless str.is_a? String

    queries << parse(normalized(str))

    self
  end

  def parslet_parse str
    parse_tree = self.class.parser_klass.new.parse str
    ApplicationSearcher::QueryTransformer.new.apply parse_tree
  rescue Parslet::ParseFailed => e
    Rails.logger.error e
    errors.add :query, "Unable to parse query"
  end

  def normalized str
    return str unless str.count('"').odd?

    errors.add :query, UNBALANCED_QUOTES_ERROR
    str + '"'
  end

  def parse str
    @input = str

    query = parslet_parse str
    query ||= ApplicationSearcher::Query.new []

    query.expand_and_alias self.class.search_keywords
    elasticsearch_query = ApplicationSearcher::ElasticsearchQuery.new self.class.field_type_mappings, query

    elasticsearch_query.to_elasticsearch
  end

  def chewy_results
    @chewy_results ||= begin
      es_results = queries.inject(self.class.index_klass) { |memo, query| memo.query query }
      chewy_modifiers.reverse.inject(es_results) { |memo, modifier| modifier.call memo }
    end
  end

  def results
    @results ||= begin
      return fetch [] if blank_query?

      fetch chewy_results
    end
  end

  def each
    return enum_for(:each) unless block_given?

    results.each do |result|
      yield result
    end
  end

  def blank_query?
    input.blank? || input.empty?
  end
end
