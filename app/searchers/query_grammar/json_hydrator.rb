module QueryGrammar
  class JSONHydrator < Parslet::Transform
    rule clause: subtree(:clause) do
      AST::Clause.new unary: clause[:unary], prefix: clause[:prefix], value: clause[:value]
    end

    rule not: subtree(:negated) do
      AST::Negator.new value: negated
    end

    rule and: subtree(:group) do
      AST::Group.new items: group, conjoiner: :and
    end

    rule or: subtree(:group) do
      AST::Group.new items: group, conjoiner: :or
    end
  end
end
