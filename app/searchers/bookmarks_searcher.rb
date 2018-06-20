class BookmarksSearcher
  class << self
    def operation name, title, **opts, &block
      operations[ name ] = { options: opts.merge( display_name: title ), block: block }
    end

    def type name, **opts
      types[ name ] = opts
    end

    def joiner name, title, **opts
      joiners[ name ] = opts.merge( display_name: title )
    end

    def index klass
      @index_klass = klass
    end

    def field name, title, **opts
      type = index_klass.mappings_hash.values.first[:properties][ name ][:type].to_sym
      fields[ name ] = opts.merge( display_name: title, type: type )
    end

    def operations
      @operations ||= {}
    end

    def types
      @types ||= {}
    end

    def joiners
      @joiners ||= {}
    end

    def index_klass
      @index_klass ||= nil
    end

    def fields
      @fields ||= {}
    end

    def config
      ops = operations.transform_values { |i| i[:options] }

      {
        operations: ops,
        types: types,
        joiners: joiners
      }
    end
  end

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
