# frozen_string_literal: true

module QueryGrammar
  module Ast
    class Group < Node
      attr_reader :items, :conjoiner

      def initialize items:, conjoiner:, **opts
        super(**opts)

        @items = items
        @conjoiner = conjoiner
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
