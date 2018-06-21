class BookmarksSearcher < ElasticsearchSearcher
  index BookmarksIndex::Bookmark

  field :uri, "URI", description: "", exclude_operations: [ "exist" ]
  field :host, "Host", description: "", exclude_operations: [ "exist" ]
  field :title, "Title", description: ""
  field :description, "Description", description: ""
  field :tags, "Tags", description: ""
  field :created_at, "Created Date", description: "", exclude_operations: [ "exist" ]
end
