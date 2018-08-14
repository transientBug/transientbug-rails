module QueryGrammar
  module AST
    class RangeClause < Node
      attr_reader :field, :low, :high

      def initialize field:, low:, high:
        @field = field
        @low = low
        @high = high
      end

      def to_s
        "#{ field }:(#{ low } #{ high })"
      end

      def to_h
        {
          range: {
            field: field,
            low: type_hash_value(low),
            high: type_hash_value(high)
          }
        }
      end

      def == other
        return false unless other.is_a? RangeClause
        field == other.field && low == other.low && high == other.high
      end
    end
  end
end
