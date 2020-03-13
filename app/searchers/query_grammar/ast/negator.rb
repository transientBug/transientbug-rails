# frozen_string_literal: true

module QueryGrammar
  module Ast
    class Negator < Node
      attr_reader :items

      def initialize items:, **opts
        super(**opts)

        @items = items
      end

      def to_h
        {
          not: items.to_h
        }
      end

      def to_s
        "NOT #{ items }"
      end

      def == other
        return false unless other.is_a? Negator

        items == other.items
      end
    end
  end
end
