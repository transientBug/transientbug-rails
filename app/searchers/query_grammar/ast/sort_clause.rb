# frozen_string_literal: true

module QueryGrammar
  module Ast
    class SortClause < Node
      attr_reader :field, :direction

      def initialize field:, direction:, **opts
        super(**opts)

        @field = field
        @direction = direction
      end

      def to_s
        direction_unary = direction == :asc ? "+" : "-"

        "#{ direction_unary }sort:#{ field }"
      end

      def to_h
        {
          sort: {
            field:,
            direction:,
          },
        }
      end

      def == other
        return false unless other.is_a? SortClause

        field == other.field && direction == other.direction
      end
    end
  end
end
