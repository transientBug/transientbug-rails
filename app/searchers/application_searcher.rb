class ApplicationSearcher
  include Enumerable

  class << self
    attr_accessor :parser_klass, :index_klass, :fields, :keywords, :field_type_mappings

    def index klass
      @index_klass = klass
    end

    def keyword key, aliases: nil, as: nil
      keywords_data << { key => { aliases: aliases, as: as } }
    end

    def keywords_data
      @keywords_data ||= []
    end
  end

  attr_reader :input
  attr_reader :errors

  def initialize
    @errors = Errors.new
  end

  def query str
    @input = str
    self
  end

  def scope raw_es_query
    @scope = raw_es_query
    self
  end

  def results
    raw_results = index_klass.query build_elasticsearch_query.to_elasticsearch
    raw_results.query @scope
    fetch raw_results
  end

  def each
    results.each
  end

  protected

  def index_klass
    self.class.index_klass
  end

  def keywords_data
    self.class.keywords_data
  end

  def keywords
    self.class.keywords ||= keywords_data.flat_map do |keyword_data|
      keyword = keyword_data.keys.first
      data = keyword_data[ keyword ]

      next as if data[:as].present?
      next keyword unless data[:aliases].present?

      all_fields = [].concat data[:aliases]
      all_fields << keyword
    end
  end

  def fields
    self.class.fields ||= keywords_data.map do |keyword_data|
      keyword_data.keys.first
    end
  end

  def field_type_mappings
    self.class.field_type_mappings ||= begin
                                         properties = index_klass.mappings_hash[:bookmark][:properties]

                                         fields.each_with_object({}) do |field, memo|
                                           memo[ field ] = properties[ field ][:type].to_sym
                                         end
                                       end
  end

  def parser_klass
    self.class.parser_klass ||= begin
                                  closure_keywords = keywords
                                  Class.new ApplicationSearcher::BaseQueryParser do
                                    fields(*closure_keywords)
                                  end
                                end
  end

  def build_elasticsearch_query
    query_ast = ApplicationSearcher::Query.new []

    begin
      parse_tree = parser_klass.new.parse input
      query_ast = ApplicationSearcher::QueryTransformer.new.apply parse_tree
      query_ast.normalize fields
    rescue Parslet::ParseFailed => e
      Rails.logger.error e
      errors.add :query, "Unable to parse query"
    end

    ApplicationSearcher::ElasticsearchQuery.new field_type_mappings, query_ast
  end

  def fetch _results
    fail NotImplementedError
  end
end
