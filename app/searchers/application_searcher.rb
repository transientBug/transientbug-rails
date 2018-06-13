class ApplicationSearcher
  include Enumerable

  UNBALANCED_QUOTES_ERROR = "Quotation marks were unbalanced, an extra quote was added to the end of the query".freeze

  class << self
    attr_reader :index_klass, :model_klass

    def model klass
      @model_klass = klass
    end

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

  def activerecord_modifiers
    @activerecord_modifiers ||= []
  end

  def query str=nil, &block
    chewy_modifiers << block if block_given?

    return self unless str.present?
    queries << str if str.is_a? Hash
    queries.concat str if str.is_a? Array

    return self unless str.is_a? String

    if str.count('"').odd?
      str = str + '"'
      errors.add :query, UNBALANCED_QUOTES_ERROR
    end

    @input = str

    self
  end

  def activerecord_modifier &block
    activerecord_modifiers << block if block_given?
  end

  def chewy_results
    @chewy_results ||= begin
      query = ApplicationSearcher::Query.new []

      begin
        parse_tree = self.class.parser_klass.new.parse input
        query = ApplicationSearcher::QueryTransformer.new.apply parse_tree
      rescue Parslet::ParseFailed => e
        Rails.logger.error e
        errors.add :query, "Unable to parse query"
      end

      query.expand_and_alias self.class.search_keywords

      ap query

      elasticsearch_query = ApplicationSearcher::ElasticsearchQuery.new self.class.field_type_mappings, query

      ap elasticsearch_query.to_elasticsearch

      es_results = self.class.index_klass.query elasticsearch_query.to_elasticsearch
      Array(queries).each do |additional_query|
        es_results = es_results.query additional_query
      end

      return es_results unless chewy_modifiers.any?
      chewy_modifiers.reverse.inject(es_results) { |memo, modifier| modifier.call memo }
    end
  end

  def fetch res
    if res.none?
      records = self.class.model_klass.none
    else
      records = self.class.model_klass.where self.class.model_klass.primary_key => res.pluck(:_id)
    end

    return records unless activerecord_modifiers.any?
    activerecord_modifiers.reverse.inject(records) { |memo, modifier| modifier.call memo }
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

  def total_pages
    chewy_results.total_pages
  end

  def current_page
    chewy_results.current_page
  end

  def limit_value
    chewy_results.limit_value
  end

  def page val
    query do |chewy|
      chewy.page val
    end

    self
  end

  def per val
    query do |chewy|
      chewy.per val
    end

    self
  end

  def blank_query?
    input.blank? || input.empty?
  end
end
