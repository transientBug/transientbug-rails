class Index
  def fields
    @fields ||= []
  end

  def types
    @types ||= {}
  end
end

class IndexDSL
  def self.build &block
    new.tap do |obj|
      obj.instance_eval(&block)
    end.index
  end

  def index
    @index ||= Index.new
  end

  def type key, can: [], default: nil
  end

  def method_missing func, *args, **opts, &block
  end
end

class ClauseDSL
  def self.build **opts, &block
    new(**opts).tap do |obj|
      obj.instance_eval(&block)
    end
  end

  def initialize **opts
  end

  def name val
  end

  def description val
  end

  def restrict_size val
  end

  def input_format val
  end

  def restricted_to vals
  end

  def compile &block
  end
end

class Operation
  def initialize field:, **opts
    @field = field
  end
end

class MatchesOperation < Operation
end

class ExistsOperation < Operation
end

class EqualsOperation < Operation
end

class RangeOperation < Operation
end

class GtRangeOperation < RangeOperation
end

class LtRangeOperation < RangeOperation
end

class SortOperation < Operation
end

class BookmarksSearcher
  class << self
    attr_reader :index

    def define_index &block
      @index = IndexDSL.build(&block)

      index.fields.each do |field|
        clause prefix: field.key do |c|
          c.name field.name
          c.description field.description

          c.input_format field.type.to_sym

          c.compile do |clause|
            field.type.default.new field: field, value: values
          end
        end
      end
    end

    def clause **opts, &block
      (@clauses ||= []) << ClauseDSL.build(**opts, &block)
    end
  end

  define_index do
    # Sets up information about which types from the search index can have what
    # operations performed on them
    type :text, can: [ MatchesOperation, ExistsOperation ], default: MatchesOperation
    type :keyword, can: [ EqualsOperation, ExistsOperation ], default: EqualsOperation
    type :number, can: [ RangeOperation, EqualsOperation, ExistsOperation ], default: EqualsOperation
    type :date, can: [ RangeOperation, EqualsOperation, ExistsOperation ], default: EqualsOperation

    # Sets up which fields are searchable, setting up the prefixs and compiles to
    # handle the correct clause type on input construction
    keyword :uri, "URI", description: ""
    keyword :host, "Host", description: "", sortable: true
    text :title, "Title", description: "", sortable: true
    text :description, "Description", description: ""
    keyword :tags, "Tags", description: "", aliases: [ :tag ]
    date :created_date, "Created Date", description: "", sortable: true
  end

  # Handles custom prefixes for various other operations such as breaking apart
  # the created_date field into two psuedofields "after" and "before" or an
  # existance "has" or sort helpers
  clause prefix: :after do |c|
    c.name "After Created Date"
    c.description <<~DESC
    DESC

    c.restrict_size 1
    c.input_format :date

    c.compile do |clause|
      GtRangeOperation.new(field: :created_at, value: clause.value)
    end
  end

  clause prefix: :before, name: "Before Created Date", description: "" do |c|
    c.restrict_size 1
    c.input_format :date

    c.compile do |clause|
      LtRangeOperation.new(field: :created_at, value: clause.value)
    end
  end

  clause prefix: :has, name: "Has property", description: "" do |c|
    c.restricted_to BookmarksSearcher.index.fields.select { |f| f.can? ExistsOperation }.map(&:known_as)

    c.compile do |clause|
      clause.values.map do |value|
        ExistsOperation.new(field: value)
      end
    end
  end

  clause prefix: :sort, name: "Sort Field and Direction", description: "" do |c|
    c.restricted_to BookmarksSearcher.index.fields.select { |f| f.sortable? }.map(&:known_as)

    c.compile do |clause|
      clause.values.map do |value|
        SortOperation.new(field: value, direction: clause.unary)
      end
    end
  end
end
