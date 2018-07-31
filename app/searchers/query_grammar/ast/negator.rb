module QueryGrammar
  module AST
    class Negator < Node
      attr_reader :items

      def initialize items:
        @items = items
      end

      def to_h
        {
          not: items.to_h
        }
      end

      def to_s
        "NOT #{ items.to_s }"
      end

      def == other
        return false unless other.is_a? Negator
        items == other.items
      end
    end
  end
end
