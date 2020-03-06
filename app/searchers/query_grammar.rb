module QueryGrammar
  class Error < StandardError
    def initialize message, line, column, original=nil, *args
      super(message, *args)

      @line = line
      @column = column
      @original = original
    end
  end

  ScanError = Class.new Error

  autoload :Cloaker, "query_grammar/cloaker"
  autoload :AST, "query_grammar/ast"

  autoload :Index, "query_grammar/index"

  autoload :Parser, "query_grammar/parser"
  autoload :Transformer, "query_grammar/transformer"
  autoload :Compiler, "query_grammar/compiler"

  class << self
    # Scans and parses an input string to generate an AST of the query against
    # the index
    #
    # TODO: Error handling
    def parse input, index:
      ast = QueryGrammar::Transformer.new(index).apply scan(input)
      ast ||= QueryGrammar::Ast::Group.new conjoiner: :and, items: [], origin: nil

      ast
    end

    # Generates a parslet parser tree from the input, which is then used with the
    # transformer to generate an AST of the query, based off of the index
    #
    # @see .parse
    def scan input
      QueryGrammar::Parser.new.parse input.strip
    rescue Parslet::ParseFailed => e
      deepest = deepest_cause e.parse_failure_cause
      line, column = deepest.source.line_and_column deepest.pos

      message = <<~MSG
        unexpected input at line #{ line } column #{ column } - #{ deepest.message } #{ input[(column - 1)..-1] }
      MSG

      fail ScanError.new(message, line, column, e)
    rescue SystemStackError => e
      fail ScanError.new("unexpected input at line 1 column 1 - #{ e }: #{ input }", 1, 1, e)
    end

    protected

    # Grabs the cause in a tree of causes which has the furthest position in the
    # input string, assuming its the clearest and best error message about what
    # went wrong while parsing the input query
    def deepest_cause cause
      return cause unless cause.children.any?

      cause.children
        .map { |xcause| deepest_cause xcause }
        .max { |xcause, other| xcause.pos.bytepos <=> other.pos.bytepos }
    end
  end
end
