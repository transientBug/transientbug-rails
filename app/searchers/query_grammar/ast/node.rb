module QueryGrammar
  module AST
    class Node
      def accept visitor
        visitor.send :"visit_#{ self.class.name.to_s.demodulize.underscore }", self
      end

      def as_json(*)
        to_h.deep_stringify_keys
      end
    end
  end
end
