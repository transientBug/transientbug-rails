class BookmarksSearcher < ElasticsearchSearcher
  index BookmarksIndex::Bookmark
  model Bookmark

  field :uri, "URI", description: "", exclude_operations: [ "exist" ]
  field :host, "Host", description: "", exclude_operations: [ "exist" ]
  field :title, "Title", description: ""
  field :description, "Description", description: ""
  field :tags, "Tags", description: ""
  field :created_at, "Created Date", description: "", exclude_operations: [ "exist" ]

  default do |input|
    next {} if input.blank? || input.empty?

    {
      should: [
        { field: :title, operation: "match", values: [ input ] },
        { field: :description, operation: "match", values: [ input ] },
        { field: :tags, operation: "equal", values: [ input ] }
      ]
    }
  end
end
