class BookmarksSearcher < QueryGrammar::Compiler::ES
  define_index do
    # Sets up information about which types from the search index can have what
    # operations performed on them
    type :text do |unary, field, values|
      next {
        bool: {
          must: values.map do |value|
            next {
              match_phrase: { field => value }
            } if value.index(" ")

            {
              match: { field => value }
            }
          end
        }
      } if values.is_a? Array

      next {
        match_phrase: { field => values }
      } if values.index(" ")

      {
        match: { field => values }
      }
    end

    type :keyword do |unary, field, values|
      next {
        terms: { field => values }
      } if values.is_a? Array

      {
        term: { field => values }
      }
    end

    type :number do |unary, field, values|
      next {
        bool: {
          must: values.map do |value|
            { term: { field => value } }
          end
        }
      } if values.is_a? Array

      {
        term: { field => values }
      }
    end

    type :date do |unary, field, values|
      next {
        bool: {
          must: values.map do |value|
            { term: { field => value } }
          end
        }
      } if values.is_a? Array

      {
        term: { field => values }
      }
    end

    # Sets up which fields are searchable, setting up the prefixs and compiles to
    # handle the correct clause type on input construction
    keyword :uri, name: "URI", description: ""
    keyword :host, name: "Host", description: "", sortable: true
    text :title, name: "Title", description: "", sortable: true
    text :description, name: "Description", description: "", existable: true
    keyword :tags, name: "Tags", description: "", aliases: [ "tag" ], existable: true
    date :created_at, name: "Created Date", description: "", aliases: [ "created_date" ], sortable: true

    default :title, :tags

    # Handles custom prefixes for various other operations such as breaking apart
    # the created_date field into two psuedofields "after" and "before" or an
    # existance "has" or sort helpers
    operator :after do
      name "After Created Date"
      description <<~DESC
      DESC

      arity 1
      type :date

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

    operator :before do
      name "Before Created Date"
      description <<~DESC
      DESC

      arity 1
      type :date

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

    operator :has do
      name "Has property"
      description <<~DESC
      DESC

      compile do |clause|
        inside = clause.values.map do |value|
          field = index.resolve_field value
          fail "unable to existance check #{ value }" unless index.existable_fields.include? field

          { exists: { field: field } }
        end

        next inside.first if inside.length == 1

        {
          bool: {
            must: inside
          }
        }
      end
    end

    operator :sort do
      name "Sort Field and Direction"
      description <<~DESC
      DESC

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
end
