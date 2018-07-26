class BookmarksSearcher < ElasticsearchSearcher
  index BookmarksIndex::Bookmark
  model Bookmark

  def search input
    parser_tree = QueryGrammar::Parser.new.parse input
    query_ast = QueryGrammar::Transformer.new.apply parser_tree

    es_query = ESQueryCompiler.new.compile self.fields, query_ast

    super es_query
  end

  field :uri, "URI", description: ""
  field :host, "Host", description: ""
  field :title, "Title", description: ""
  field :description, "Description", description: ""
  field :tags, "Tags", description: "", aliases: [ :tag ]

  field :before, "Before Created Date", description: "" do |input|
  end

  field :after, "After Created Date", description: "" do |input|
  end

  field :has, "Has property", description: "" do |input|
  end
end
