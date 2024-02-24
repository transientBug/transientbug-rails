# frozen_string_literal: true

class BookmarksSearcher < ApplicationSearcher
  define_index do
    # Defines the available types of specialized prefix searches
    # in the query. The symbol name gets mapped to a function that
    # registers a prefix
    type :text do |clause|
      clause.values.map do |value|
        QueryGrammar::Ast::MatchClause.new(
          field: clause.prefix,
          value:,
          origin: clause
        )
      end
    end

    type :keyword do |clause|
      clause.values.map do |value|
        QueryGrammar::Ast::EqualClause.new(
          field: clause.prefix,
          value:,
          origin: clause
        )
      end
    end

    type :number do |clause|
      clause.values.map do |value|
        QueryGrammar::Ast::EqualClause.new(
          field: clause.prefix,
          value:,
          origin: clause
        )
      end
    end

    type :date do |clause|
      clause.values.map do |value|
        QueryGrammar::Ast::EqualClause.new(
          field: clause.prefix,
          value:,
          origin: clause
        )
      end
    end

    # This sets up the prefixes that are available in the query
    # as well as what "type" they parse as as defined by the types
    # above
    field :uri,
          type: :keyword,
          name: "URI",
          description: ""

    field :host,
          type: :keyword,
          name: "Host",
          description: "",
          sortable: true

    field :title,
          type: :text,
          name: "Title",
          description: "",
          sortable: true

    field :description,
          type: :text,
          name: "Description/Notes",
          description: "",
          existable: true

    field :tags,
          type: :keyword,
          name: "Tags",
          description: "",
          aliases: [ "tag" ],
          existable: true

    field :created_at,
          type: :date,
          name: "Created at Date",
          description: "",
          aliases: [ "created_date" ],
          sortable: true

    # Handles custom prefixes for various other operations such as breaking apart
    # the created_date field into two pseudo fields "after" and "before" or an
    # existence "has" or sort helpers
    operator :after do
      name "Created After Date"
      description <<~DESC
      DESC

      arity 1
      types :date

      parse do |clause|
        QueryGrammar::Ast::GtRangeClause.new(
          field: :created_at,
          value: clause.values.first,
          origin: clause
        )
      end
    end

    operator :before do
      name "Created Before Date"
      description <<~DESC
      DESC

      arity 1
      types :date

      parse do |clause|
        QueryGrammar::Ast::LtRangeClause.new(
          field: :created_at,
          value: clause.values.first,
          origin: clause
        )
      end
    end

    operator :between do
      name "Created Between Dates"
      description <<~DESC
      DESC

      arity 2
      types :date

      parse do |clause|
        QueryGrammar::Ast::RangeClause.new(
          field: :created_at,
          low: clause.values.first,
          high: clause.values.second,
          origin: clause
        )
      end
    end

    operator :has do
      name "Has property"
      description <<~DESC
      DESC

      parse do |clause|
        clause.values.map do |value|
          field = resolve_field value

          QueryGrammar::Ast::ExistClause.new(
            field:,
            origin: clause
          )
        end
      end
    end

    operator :sort do
      name "Sort Field and Direction"
      description <<~DESC
      DESC

      parse do |clause|
        clause.values.map do |value|
          field = resolve_field value

          QueryGrammar::Ast::SortClause.new(
            field:,
            direction: (clause.unary == "+" ? :asc : :desc),
            origin: clause
          )
        end
      end
    end

    fallback do |clause|
      QueryGrammar::Ast::MatchClause.new(
        field: :title,
        value: "#{ clause.unary }#{ clause.prefix }:#{ clause.values.join ' ' }",
        origin: clause
      )
    end

    # Default fields to search on
    default :title, :tags, :uri
  end

  use_compiler QueryGrammar::Compiler::Arel.new(Bookmark)

  execute_query do |compiled_query|
    # pp compiled_query
    Bookmark.left_joins(:tags)
      .where(compiled_query[:query])
      .order(compiled_query[:order])
  end
end
