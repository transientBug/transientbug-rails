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

__END__

# Early thoughts
earth +tag:computers +( created_date:[2014-01-01,2018-06-14] ) -host:wired.com

earth tags:computers 2014-01-01<created_date<=2018-06-14 NOT host:wired.com

# SQL like thoughts
((title ~= "hallo") OR (description ~= "hallo") OR NOT (host = "wired.com")) AND (user_is = 1) AND NOT (tags EXIST)
