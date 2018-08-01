module QueryGrammar
  Error          = Class.new StandardError
  ParseError     = Class.new Error
  CompileError   = Class.new Error

  autoload :AST, "query_grammar/ast"
  autoload :Parser, "query_grammar/parser"
  autoload :Transformer, "query_grammar/transformer"

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

  class Compiler
    class Cloaker < BasicObject
      attr_reader :bind, :closure

      def initialize bind:, closure: nil
        @bind = bind
        @closure = closure
      end

      def cloak *args, &block
        closure ||= block.binding

        # Ruby blocks don't closure over more than local variables, but we can
        # get around that with this "cloaker" hack. First we make an
        # unboundmethod which we rebind to our current instance. We also keep the
        # blocks original binding and with the method missing magic, proxy out to
        # it, which allows us to closure over methods and more from where the
        # block was defined at.
        executor = bind.class.class_eval do
          define_method :dsl_executor, &block
          meth = instance_method :dsl_executor
          remove_method :dsl_executor
          meth
        end

        with_closure_from closure do
          executor.bind(bind).call(*args)
        end
      end

      def with_closure_from binding
        @_parent_binding = binding
        result = yield
        @_parent_binding = nil
        result
      end

      # rubocop:disable Style/MethodMissing
      def respond_to_missing? *args
        @_parent_binding.respond_to_missing?(*args)
      end

      def method_missing method, *args, **opts, &block
        args << opts if opts.any?
        @_parent_binding.send method, *args, &block
      end
      # rubocop:enable Style/MethodMissing
    end

    def self.visitors
      @visitors ||= {}
    end

    def self.visit klass, &block
      visitors[ klass ] = block
    end

    def visit node
      visitor = self.class.visitors[ node.class ]
      Cloaker.new(bind: self).cloak node, &visitor
    end
  end

  # Two example visitors, these should output the same content as the AST #to_s
  # and #to_h outputs, respecfully.
  class PrintCompiler < Compiler
    visit QueryGrammar::AST::Group do |group|
      inside = group.items.map { |i| visit i }.join " #{ group.conjoiner.to_s.upcase } "

      "(#{ inside })"
    end

    visit QueryGrammar::AST::Negator do |negator|
      "NOT #{ negator.items.map { |i| visit i } }"
    end

    visit QueryGrammar::AST::Clause do |clause|
      val = Array(clause.value).map do |entry|
        next "\"#{ entry }\"" if entry.index(" ")
        entry
      end.join " "

      val = "(#{ val })" if clause.value.is_a? Array

      "#{ clause.unary }#{ clause.prefix }#{ clause.prefix ? ":" : "" }#{ val }"
    end
  end

  class HashCompiler < Compiler
    visit QueryGrammar::AST::Group do |group|
      {
        group.conjoiner => group.items.map { |i| visit i }
      }
    end

    visit QueryGrammar::AST::Negator do |negator|
      {
        not: negator.items.map { |i| visit i }
      }
    end

    visit QueryGrammar::AST::Clause do |clause|
      {
        clause: { unary: clause.unary, prefix: clause.prefix, value: clause.value }.compact
      }
    end
  end

  class ESIndex
    def sortable_fields
      [ "created_at", "title", "host" ]
    end

    def existable_fields
      [ "tags", "description" ]
    end

    def default_fields
      [ "title", "tags" ]
    end

    def aliases
      # alias => field
      {
        "created_date" => "created_at",
        "tag" => "tags"
      }
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

    visit QueryGrammar::AST::Group do |group|
      joiner = group.conjoiner == :or ? :should : :must
      inside = group.items.map { |i| visit i }.compact

      {
        bool: {
          joiner => inside
        }
      }
    end

    visit QueryGrammar::AST::Negator do |negator|
      inside = negator.items.map { |i| visit i }.compact

      {
        bool: {
          must_not: inside
        }
      }
    end

    visit QueryGrammar::AST::Clause do |clause|
      # if index.has_field? clause.prefix
        # index.check_arity clause.value
        # index.check_type clause.value

        # operation = index.operation_for clause.prefix
      # end

      if clause.prefix.blank?
        next {
          bool: {
            should: index.default_fields.map do |field|
              {
                term: { field => clause.value }
              }
            end
          }
        }
      elsif clause.prefix == "after"
        value = clause.value

        if value.is_a? Array
          throw "too many dates given" if value.length > 1
          value = value.first
        end

        throw "date required" unless value.is_a? Date

        next {
          range: {
            created_at: {
              gt: value
            }
          }
        }
      elsif clause.prefix == "before"
        value = clause.value

        if value.is_a? Array
          throw "too many dates given" if value.length > 1
          value = value.first
        end

        throw "date required" unless value.is_a? Date

        next {
          range: {
            created_at: {
              lt: value
            }
          }
        }
      elsif clause.prefix == "has"
        fields = clause.values.map do |value|
          field = index.resolve_field value
          fail "unable to existance check #{ value }" unless index.existable_fields.include? field

          field
        end

        next {
          bool: {
            must: fields.map do |field|
              { exists: { field: field } }
            end
          }
        }
      elsif clause.prefix == "sort"
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

        next
      end

      {
        term: { index.resolve_field(clause.prefix) => clause.value }
      }
    end
  end
end
