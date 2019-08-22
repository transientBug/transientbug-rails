module QueryGrammar
  module Ast
    class ExistClause < Node
      attr_reader :field

      def initialize field:, **opts
        super(**opts)

        @field = field
      end

      def to_s
        "has:#{ field }"
      end

      def to_h
        {
          exist: {
            field: field
          }
        }
      end

      def == other
        return false unless other.is_a? ExistClause
        field == other.field
      end
    end
  end
end
