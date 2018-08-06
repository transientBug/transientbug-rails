module QueryGrammar
  module AST
    class Group < Node
      attr_reader :items, :conjoiner

      def initialize items:, conjoiner:
        @items = items
        @conjoiner = conjoiner
      end

      def accept visitor
        items.each do |item|
          item.accept visitor
        end

        visitor.visit_group self
      end

      def to_h
        {
          conjoiner => items.map(&:to_h)
        }
      end

      def to_s
        inside = items.map(&:to_s).join(" #{ conjoiner.to_s.upcase } ")
        "(" + inside + ")"
      end

      def == other
        return false unless other.is_a? Group
        items == other.items && conjoiner == other.conjoiner
      end
    end
  end
end
