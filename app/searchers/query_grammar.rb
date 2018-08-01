module QueryGrammar
  Error          = Class.new StandardError
  ParseError     = Class.new Error
  CompileError   = Class.new Error

  autoload :AST, "query_grammar/ast"
  autoload :Parser, "query_grammar/parser"
  autoload :Transformer, "query_grammar/transformer"
  autoload :Compiler, "query_grammar/compiler"

  def self.rehydrate json
    parsed_json = json.is_a?(String) ? JSON.parse(json) : json
    QueryGrammar::JSONHydrator.new.apply parsed_json.deep_symbolize_keys
  end

  def self.parse input
    QueryGrammar::Transformer.new.apply QueryGrammar::Parser.new.parse(input.strip)
  rescue Parslet::ParseFailed => e
    deepest = deepest_cause e.parse_failure_cause
    line, column = deepest.source.line_and_column deepest.pos

    # TODO: Make this fail with a more informative error rather than just a
    # message. An object with a reference to the Parslet error and info such as
    # the column and line for highlighting in the UI
    fail ParseError, "unexpected input at line #{line} column #{column} - #{deepest.message} #{input[column-1..-1]}"
  rescue SystemStackError => e
    fail ParseError, "unexpected input at line 1 column 1 - #{e}: #{input}"
  end

  def self.deepest_cause cause, depth=0
    # puts "#{ " |"*depth } ^"
    # puts "#{ " |"*depth } |---> At depth #{ depth } with #{ cause.children.length } children"

    if cause.children.any?
      causes = cause.children.map { |xcause| deepest_cause xcause, depth+1 }
      cause = causes.max { |xcause, other| xcause.pos.bytepos <=> other.pos.bytepos }

      # puts "#{ " |"*depth }---= Found #{ cause.pos.bytepos } pos"
      cause
    else
      # puts "#{ " |"*depth }---$ Found #{ cause.pos.bytepos } pos"
      cause
    end
  end

  class ESIndex
    def fields
      {
        "uri" => {
          aliases: [],
          type: :keyword,
          existable: false,
          sortable: false,
          default: false,
        },

        "host" => {
          aliases: [],
          type: :keyword,
          existable: false,
          sortable: true,
          default: false,
        },

        "title" => {
          aliases: [],
          type: :text,
          existable: false,
          sortable: true,
          default: true,
        },

        "description" => {
          aliases: [],
          type: :text,
          existable: true,
          sortable: false,
          default: false,
        },

        "tags" => {
          aliases: [ "tag" ],
          type: :keyword,
          existable: true,
          sortable: false,
          default: true,
        },

        "created_at" => {
          aliases: [ "created_date" ],
          type: :date,
          existable: false,
          sortable: true,
          default: false,
        }
      }
    end

    def sortable_fields
      fields.map do |(field, data)|
        field if data[:sortable]
      end.compact
    end

    def existable_fields
      fields.map do |(field, data)|
        field if data[:existable]
      end.compact
    end

    def default_fields
      fields.map do |(field, data)|
        field if data[:default]
      end.compact
    end

    def aliases
      # alias => field
      fields.each_with_object({}) do |(field, data), memo|
        data[:aliases].each do |aliass|
          memo[ aliass ] = field
        end
      end
    end

    def resolve_field field_or_alias
      return field_or_alias unless aliases.key? field_or_alias
      aliases[ field_or_alias ]
    end
  end

  class ESCompiler < Compiler
    attr_reader :context, :index

    def initialize
      @context = {
        query: {},
        sort: {}
      }

      @index = ESIndex.new
    end

    def compile ast
      result = visit ast
      context[:query] = result

      context
    end

    def after_op clause
      value = clause.value

      if value.is_a? Array
        throw "too many dates given" if value.length > 1
        value = value.first
      end

      throw "date required" unless value.is_a? Date

      {
        range: {
          created_at: {
            gt: value
          }
        }
      }
    end

    def before_op clause
      value = clause.value

      if value.is_a? Array
        throw "too many dates given" if value.length > 1
        value = value.first
      end

      throw "date required" unless value.is_a? Date

      {
        range: {
          created_at: {
            lt: value
          }
        }
      }
    end

    def has_op clause
      fields = clause.values.map do |value|
        field = index.resolve_field value
        fail "unable to existance check #{ value }" unless index.existable_fields.include? field

        field
      end

      {
        bool: {
          must: fields.map do |field|
            { exists: { field: field } }
          end
        }
      }
    end

    def sort_op clause
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

      nil
    end

    def operation_for field, values
      field_data = index.fields[ index.resolve_field field ]

      throw "unable to search on non-existant field #{ field }" unless field_data

      case field_data[:type]
      when :text
        {
          match: { field => values }
        }
      when :keyword
        {
          term: { field => values }
        }
      when :date
        {
          term: { field => values }
        }
      else throw "unknown type #{ field_data[:type] }"
      end
    end

    visit QueryGrammar::AST::Group do |group|
      joiner = group.conjoiner == :or ? :should : :must
      inside = group.items.map { |i| visit i }.compact

      # todo: flatten, if there is a nested bool in `inside` then it should be
      # merged with this outer layer according to bool logic and precedence
      {
        bool: {
          joiner => inside
        }
      }
    end

    visit QueryGrammar::AST::Negator do |negator|
      if negator.items.is_a?(Array)
        inside = negator.items.map { |i| visit i }.compact
      else
        inside = visit negator.items
      end

      {
        bool: {
          must_not: inside
        }
      }
    end

    visit QueryGrammar::AST::Clause do |clause|
      if clause.prefix.blank?
        next {
          bool: {
            should: index.default_fields.map do |field|
              operation_for field, clause.value
            end
          }
        }
      elsif respond_to? :"#{ clause.prefix }_op"
        next send :"#{ clause.prefix }_op", clause
      end

      operation_for clause.prefix, clause.value
    end
  end
end
