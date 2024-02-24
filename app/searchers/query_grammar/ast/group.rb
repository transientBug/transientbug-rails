# frozen_string_literal: true

module QueryGrammar
  module Ast
    class Group < Node
      attr_reader :items, :joiner

      def initialize items:, joiner:, **opts
        super(**opts)

        @items = items
        @joiner = joiner
      end

      def to_h
        {
          joiner => items.map(&:to_h),
        }
      end

      def to_s
        inside = items.map(&:to_s).join(" #{ joiner.to_s.upcase } ")
        "(#{ inside })"
      end

      def == other
        return false unless other.is_a? Group

        items == other.items && joiner == other.joiner
      end
    end
  end
end
