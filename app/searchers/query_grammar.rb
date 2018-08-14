module QueryGrammar
  Error          = Class.new StandardError
  ScanError      = Class.new Error

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
      QueryGrammar::Transformer.new(index).apply scan(input)
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

      # TODO: Make this fail with a more informative error rather than just a
      # message. An object with a reference to the Parslet error and info such as
      # the column and line for highlighting in the UI
      fail ScanError, "unexpected input at line #{ line } column #{ column } - #{ deepest.message } #{ input[(column - 1)..-1] }"
    rescue SystemStackError => e
      fail ScanError, "unexpected input at line 1 column 1 - #{ e }: #{ input }"
    end

    protected

    # Grabs the cause in a tree of causes which has the furthest position in the
    # input string, assuming its the clearest and best error message about what
    # went wrong while parsing the input query
    def deepest_cause cause, depth=0
      cause unless cause.children.any?

      cause.children
        .map { |xcause| deepest_cause xcause, depth + 1 }
        .max { |xcause, other| xcause.pos.bytepos <=> other.pos.bytepos }
    end
  end
end
