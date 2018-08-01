module QueryGrammar
  module AST
    class Node
      def as_json(*)
        to_h.deep_stringify_keys
      end
    end
  end
end
