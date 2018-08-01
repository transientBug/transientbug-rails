module QueryGrammar
  class Transformer < Parslet::Transform
    rule term: simple(:term) do
      term.to_s
    end

    rule date: simple(:date) do
      Date.strptime date, "%Y-%m-%d"
    end

    rule phrase: simple(:phrase) do
      phrase.to_s
    end

    rule phrase: sequence(:phrase) do
      ""
    end

    rule term_list: subtree(:term_list) do
      term_list
    end

    rule clause: subtree(:clause) do
      QueryGrammar::AST::Clause.new unary: clause[:unary], prefix: clause[:prefix], value: clause[:value]
    end

    rule negator: simple(:negator), clause: subtree(:clause) do
      QueryGrammar::AST::Negator.new items: QueryGrammar::AST::Clause.new(unary: clause[:unary], prefix: clause[:prefix], value: clause[:value])
    end

    rule group: subtree(:group) do
      QueryGrammar::AST::Group.new items: group[:values], conjoiner: group[:conjoiner].downcase.to_sym
    end

    rule expression: subtree(:expression) do
      expression
    end

    rule negator: simple(:negator), expression: subtree(:expression) do
      QueryGrammar::AST::Negator.new items: expression
    end
  end
end
