class BookmarksSearcher
  class << self
    def operation name, **opts, &block
      operations[ name ] = { options: opts, block: block }
    end

    def type name, **opts
      types[ name ] = opts
    end

    def index klass
      @index_klass = klass
    end

    def field name, title, **opts
      fields[ name ] = opts.merge( display_name: title )
    end

    def operations
      @operations ||= {}
    end

    def types
      @types ||= {}
    end

    def index_klass
      @index_klass ||= nil
    end

    def fields
      @fields ||= {}
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

  operation "less_than" do |field, (value)|
    {
      range: {
        field => {
          lt: value
        }
      }
    }
  end

  operation "less_than_or_equal" do |field, (value)|
    {
      range: {
        field => {
          lte: value
        }
      }
    }
  end

  operation "equal" do |field, (value)|
    {
      term: {
        field => value
      }
    }
  end

  operation "greater_than_or_equal" do |field, (value)|
    {
      range: {
        field => {
          gte: value
        }
      }
    }
  end

  operation "greater_than" do |field, (value)|
    {
      range: {
        field => {
          gt: value
        }
      }
    }
  end

  operation "match" do |field, (value)|
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

  type :number, operations: [
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
  ]

  type :date, operations: [
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
  ]

  index BookmarksIndex

  field :uri, "URI", description: "", exclude_operations: [ "exists" ]
  field :host, "Host", description: "", exclude_operations: [ "exists" ]
  field :title, "Title", description: ""
  field :description, "Description", description: ""
  field :tags, "Tags", description: ""
  field :created_at, "Created Date", description: "", exclude_operations: [ "exists" ]
end
