class BookmarksSearcher
  class << self
    def operation *args, **opts, &block
    end

    def type *args, **opts, &block
    end

    def field *args, **opts, &block
    end
  end

  operation "[between]", takes: 2 do |field, (lower, higher)|
    {
      range: {
        field => {
          gt: lower,
          lt: higher
        }
      }
    }
  end

  operation "[between)", takes: 2 do |field, (lower, higher)|
    {
      range: {
        field => {
          gt: lower,
          lt: higher
        }
      }
    }
  end

  operation "(between]", takes: 2 do |field, (lower, higher)|
    {
      range: {
        field => {
          gt: lower,
          lt: higher
        }
      }
    }
  end

  operation "(between)", takes: 2 do |field, (lower, higher)|
    {
      range: {
        field => {
          gt: lower,
          lt: higher
        }
      }
    }
  end

  operation "less_than" do |field, value|
    {
      range: {
        field => {
          lt: value
        }
      }
    }
  end

  operation "less_than_or_equal" do |field, value|
    {
      range: {
        field => {
          lte: value
        }
      }
    }
  end

  operation "equals" do |field, value|
    {
      term: {
        field => value
      }
    }
  end

  operation "greater_than_or_equal" do |field, value|
    {
      range: {
        field => {
          gte: value
        }
      }
    }
  end

  operation "greater_than" do |field, value|
    {
      range: {
        field => {
          gt: value
        }
      }
    }
  end

  operation "match" do |field, value|
    {
      match: {
        field => value
      }
    }
  end

  operation "exist", takes: 0 do |field|
    {
      exists: {
        field: field
      }
    }
  end

  type :text, operations: [ "match", "exists" ]
  type :keyword, operations: [ "equals", "exists" ]
  type :number, operations: [ "[between]", "[between)", "(between]", "(between)", "less_than", "less_than_or_equal", "equal", "greater_than_or_equal", "greater_than" ]
  type :date, operations: [ "[between]", "[between)", "(between]", "(between)", "less_than", "less_than_or_equal", "equal", "greater_than_or_equal", "greater_than" ]

  index BookmarksIndex

  field :uri, "URI", description: ""
  field :host, "Host", description: ""
  field :title
  field :description
  field :tags
  field :created_at
end
