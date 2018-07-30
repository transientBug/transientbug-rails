module QueryGrammar
  Error          = Class.new StandardError
  ParseError     = Class.new Error
  # TransformError = Class.new Error

  module AST
    class Clause
      def initialize  unary: nil, prefix: nil, value: nil
        @unary = unary
        @prefix = prefix
        @value = value
      end

      def as_json(*)
        {
          "clause" => {
            "unary" => @unary,
            "prefix" => @prefix,
            "value" => @value.as_json
          }.compact
        }
      end
    end

    class Negator
      def initialize value:
        @value = value
      end

      def as_json(*)
        {
          "not" => @value.as_json
        }
      end
    end

    class Group
      def initialize items:, conjoiner:
        @items = items
        @conjoiner = conjoiner
      end

      def as_json(*)
        {
          @conjoiner.to_s => @items.as_json
        }
      end
    end
  end

  autoload :Parser, "query_grammar/parser"
  autoload :Transformer, "query_grammar/transformer"

  def self.rehydrate json
    parsed_json = json.is_a?(String) ? JSON.parse(json) : json
    QueryGrammar::JSONHydrator.new.apply parsed_json.deep_symbolize_keys
  end

  def self.parse input
    QueryGrammar::Transformer.new.apply QueryGrammar::Parser.new.parse(input)
  rescue Parslet::ParseFailed => e
    deepest = deepest_cause e.parse_failure_cause
    line, column = deepest.source.line_and_column deepest.pos

    fail ParseError, "unexpected input at line #{line} column #{column}"
  rescue SystemStackError => e
    fail ParseError, "unexpected input at line 1 column 1"
  end

  def self.deepest_cause cause
    if cause.children.any?
      deepest_cause cause.children.first
    else
      cause
    end
  end
end
