class BookmarkSearcher < ApplicationSearcher
  USER_SEARCHABLE_FIELDS = [
    :uri,
    :host,
    :title,
    :description,
    :tags
  ].freeze

  FIELD_TO_TYPE = USER_SEARCHABLE_FIELDS.each_with_object({}) do |field, memo|
    properties = BookmarksIndex::Bookmark.mappings_hash[:bookmark][:properties]
    memo[ field ] = properties[ field ][:type].to_sym
  end.freeze

  class BookmarksQueryParser < ApplicationSearcher::BaseQueryParser
    fields(*USER_SEARCHABLE_FIELDS)
  end

  def query_search query
    query_ast = ApplicationSearcher::Query.new []

    begin
      parse_tree = BookmarksQueryParser.new.parse query
      query_ast = ApplicationSearcher::QueryTransformer.new.apply parse_tree
      query_ast.normalize USER_SEARCHABLE_FIELDS
    rescue Parslet::ParseFailed => e
      Rails.logger.error e
      errors.add :query, "Unable to parse query. Are you missing a quote?"
    end

    elasticsearch_query = ApplicationSearcher::ElasticsearchQuery.new FIELD_TO_TYPE, query_ast

    BookmarksIndex::Bookmark.query elasticsearch_query.to_elasticsearch
  end
end
