module QueryGrammar
  Error          = Class.new StandardError
  ParseError     = Class.new Error
  # TransformError = Class.new Error

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

  class Visitor
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

    def self.accept ast
      ast.accept new
    end

    def visit node
      visitor = self.class.visitors[ node.class ]
      Cloaker.new(bind: self).cloak node, &visitor
    end
  end

  class PrintVisitor < Visitor
    visit QueryGrammar::AST::Group do |group|
      inside = group.items.map { |i| i.accept self }.join " #{ group.conjoiner.to_s.upcase } "

      "(#{ inside })"
    end

    visit QueryGrammar::AST::Negator do |negator|
      "NOT #{ negator.items.map { |i| i.accept self } }"
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

  class HashVisitor < Visitor
    visit QueryGrammar::AST::Group do |group|
      {
        group.conjoiner => group.items.map { |i| i.accept self }
      }
    end

    visit QueryGrammar::AST::Negator do |negator|
      {
        not: negator.items.map { |i| i.accept self }
      }
    end

    visit QueryGrammar::AST::Clause do |clause|
      {
        clause: { unary: clause.unary, prefix: clause.prefix, value: clause.value }.compact
      }
    end
  end

  class ESVisitor < Visitor
    visit QueryGrammar::AST::Group do |group|
      joiner = group.conjoiner == :or ? :should : :must
      inside = group.items.map { |i| i.accept self }

      {
        bool: {
          joiner => inside
        }
      }
    end

    visit QueryGrammar::AST::Negator do |negator|
      inside = negator.items.map { |i| i.accept self }

      {
        bool: {
          must_not: inside
        }
      }
    end

    visit QueryGrammar::AST::Clause do |clause|
      {
        term: { clause.prefix => clause.value }
      }
    end
  end
end
