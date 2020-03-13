# frozen_string_literal: true

module QueryGrammar
  module Ast
    class Node
      attr_reader :origin

      def initialize origin:
        @origin = origin
      end

      # Should return a generic, human readable version of the query. Useful
      # for debugging
      def to_s
        fail NotImplementedError
      end

      # Should return a generic, machine and human readable version of the
      # query. Useful for debugging and storing
      def to_h
        fail NotImplementedError
      end

      def == _other
        fail NotImplementedError
      end

      def accept visitor
        visitor.send :"visit_#{ self.class.name.to_s.demodulize.underscore }", self
      end

      def as_json(*)
        to_h.deep_stringify_keys
      end

      protected

      def type_hash_value val
        type = :date if val.is_a? Date
        type ||= val.index(" ") ? :phrase : :term

        {
          type: type,
          value: val.as_json
        }
      end
    end
  end
end
