module QueryGrammar
  class JSONHydrator < Parslet::Transform
    rule clause: subtree(:clause) do
      QueryGrammar::AST::Clause.new unary: clause[:unary], prefix: clause[:prefix], value: clause[:value]
    end

    rule not: subtree(:negated) do
      QueryGrammar::AST::Negator.new items: negated
    end

    rule and: subtree(:group) do
      QueryGrammar::AST::Group.new items: group, conjoiner: :and
    end

    rule or: subtree(:group) do
      QueryGrammar::AST::Group.new items: group, conjoiner: :or
    end
  end
end
