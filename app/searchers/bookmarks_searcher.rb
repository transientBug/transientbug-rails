class BookmarksSearcher < QueryGrammar::Compiler::ES
  define_index do
    # Sets up information about which types from the search index can have what
    # operations performed on them
    type :text
    type :keyword
    type :number
    type :date

    # Sets up which fields are searchable, setting up the prefixs and compiles to
    # handle the correct clause type on input construction
    keyword :uri, "URI", description: ""
    keyword :host, "Host", description: "", sortable: true
    text :title, "Title", description: "", sortable: true
    text :description, "Description", description: "", existable: true
    keyword :tags, "Tags", description: "", aliases: [ :tag ], existable: true
    date :created_at, "Created Date", description: "", aliases: [ "created_date" ], sortable: true

    default :title, :tags
  end

  # Handles custom prefixes for various other operations such as breaking apart
  # the created_date field into two psuedofields "after" and "before" or an
  # existance "has" or sort helpers
  clause prefix: :after do
    name "After Created Date"
    description <<~DESC
    DESC

    arity 1
    input_format :date

    compile do |clause|
      {
        range: {
          created_at: {
            gt: clause.values.first
          }
        }
      }
    end
  end

  clause prefix: :before, name: "Before Created Date", description: "" do
    arity 1
    input_format :date

    compile do |clause|
      {
        range: {
          created_at: {
            lt: clause.values.first
          }
        }
      }
    end
  end

  clause prefix: :has, name: "Has property", description: "" do
    compile do |clause|
      fields = clause.values.map do |value|
        field = index.resolve_field value
        fail "unable to existance check #{ value }" unless index.existable_fields.include? field

        field
      end

      clause.values.map do |value|
        {
          bool: {
            must: fields.map do |field|
              { exists: { field: field } }
            end
          }
        }
      end
    end
  end

  clause prefix: :sort, name: "Sort Field and Direction", description: "" do
    compile do |clause|
      fields = clause.values.map do |value|
        field = index.resolve_field value
        fail "unsortable field #{ value }" unless index.sortable_fields.include? field

        field
      end

      direction = clause.unary == "+" ? :asc : :desc

      sorts = fields.each_with_object({}) do |value, memo|
        memo[ value ] = { order: direction }
      end

      context[:sort].merge! sorts
    end
  end
end
