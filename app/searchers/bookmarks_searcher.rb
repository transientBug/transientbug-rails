class BookmarksSearcher < ApplicationSearcher
  define_index do
    # Sets up information about which types from the search index can have what
    # operations performed on them
    type :text do |clause|
      clause.values.map do |value|
        QueryGrammar::AST::MatchClause.new field: clause.prefix, value: value
      end
    end

    type :keyword do |clause|
      clause.values.map do |value|
        QueryGrammar::AST::EqualClause.new field: clause.prefix, value: value
      end
    end

    type :number do |clause|
      clause.values.map do |value|
        QueryGrammar::AST::EqualClause.new field: clause.prefix, value: value
      end
    end

    type :date do |clause|
      clause.values.map do |value|
        QueryGrammar::AST::EqualClause.new field: clause.prefix, value: value
      end
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
      name "Created After Date"
      description <<~DESC
      DESC

      arity 1
      types :date

      parse do |clause|
        QueryGrammar::AST::GtRangeClause.new field: :created_at, value: clause.values.first
      end
    end

    operator :before do
      name "Created Before Date"
      description <<~DESC
      DESC

      arity 1
      types :date

      parse do |clause|
        QueryGrammar::AST::LtRangeClause.new field: :created_at, value: clause.values.first
      end
    end

    operator :between do
      name "Created Between Dates"
      description <<~DESC
      DESC

      arity 2
      types :date

      parse do |clause|
        QueryGrammar::AST::RangeClause.new field: :created_at, low: clause.values.first, high: clause.values.second
      end
    end

    operator :has do
      name "Has property"
      description <<~DESC
      DESC

      parse do |clause|
        clause.values.map do |value|
          QueryGrammar::AST::ExistClause.new field: value
        end
      end
    end

    operator :sort do
      name "Sort Field and Direction"
      description <<~DESC
      DESC

      parse do |clause|
        clause.values.map do |value|
          QueryGrammar::AST::SortClause.new field: value, direction: (clause.unary == "+" ? :asc : :desc)
        end
      end
    end
  end

  use_compiler QueryGrammar::Compiler::ES

  execute_query do |compiled_query|
    BookmarksIndex::Bookmark.query(compiled_query[:query]).order(compiled_query[:sort])
  end
end
