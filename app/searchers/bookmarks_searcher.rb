class BookmarksSearcher < ApplicationSearcher
  operation "[between]", "After till Before", parameters: 2 do |field, (lower, higher)|
    {
      range: {
        field => {
          gt: lower,
          lt: higher
        }
      }
    }
  end

  operation "[between)", "After till Before or On", parameters: 2 do |field, (lower, higher)|
    {
      range: {
        field => {
          gt: lower,
          lt: higher
        }
      }
    }
  end

  operation "(between]", "On or After till Before", parameters: 2 do |field, (lower, higher)|
    {
      range: {
        field => {
          gt: lower,
          lt: higher
        }
      }
    }
  end

  operation "(between)", "On or After till Before or On", parameters: 2 do |field, (lower, higher)|
    {
      range: {
        field => {
          gt: lower,
          lt: higher
        }
      }
    }
  end

  operation "less_than", "Less Than" do |field, (value)|
    {
      range: {
        field => {
          lt: value
        }
      }
    }
  end

  operation "less_than_or_equal", "Less Than or Equal" do |field, (value)|
    {
      range: {
        field => {
          lte: value
        }
      }
    }
  end

  operation "equal", "Equals" do |field, (value)|
    {
      term: {
        field => value
      }
    }
  end

  operation "greater_than_or_equal", "Greater Than or Equal" do |field, (value)|
    {
      range: {
        field => {
          gte: value
        }
      }
    }
  end

  operation "greater_than", "Greater Than" do |field, (value)|
    {
      range: {
        field => {
          gt: value
        }
      }
    }
  end

  operation "match", "Matches" do |field, (value)|
    {
      match: {
        field => value
      }
    }
  end

  operation "exist", "Exists", parameters: 0 do |field|
    {
      exists: {
        field: field
      }
    }
  end

  type :text, supported_operations: [ "match", "exist" ], default_operation: "match"
  type :keyword, supported_operations: [ "equal", "exist" ], default_operation: "equal"

  type :number, supported_operations: [
    "[between]",
    "[between)",
    "(between]",
    "(between)",
    "less_than",
    "less_than_or_equal",
    "equal",
    "greater_than_or_equal",
    "greater_than",
    "exist"
  ], default_operation: "equal"

  type :date, supported_operations: [
    "[between]",
    "[between)",
    "(between]",
    "(between)",
    "less_than",
    "less_than_or_equal",
    "equal",
    "greater_than_or_equal",
    "greater_than",
    "exist"
  ], default_operation: "equal"

  joiner :should, "Or"
  joiner :must, "And"
  joiner :must_not, "Not"

  index BookmarksIndex::Bookmark

  field :uri, "URI", description: "", exclude_operations: [ "exists" ]
  field :host, "Host", description: "", exclude_operations: [ "exists" ]
  field :title, "Title", description: ""
  field :description, "Description", description: ""
  field :tags, "Tags", description: ""
  field :created_at, "Created Date", description: "", exclude_operations: [ "exists" ]
end
