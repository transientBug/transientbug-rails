module QueryGrammar
  class JSONHydrator < Parslet::Transform
    rule clause: subtree(:clause) do
      values = clause[:values].map do |value|
        next Date.strptime value[:value], "%Y-%m-%d" if value[:type] == :date

        value[:value]
      end

      QueryGrammar::AST::Clause.new unary: clause[:unary], prefix: clause[:prefix], value: values
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
