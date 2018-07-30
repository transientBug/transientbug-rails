module QueryGrammar
  class Transformer < Parslet::Transform
    rule term: simple(:term) do
      term.to_s
    end

    rule phrase: simple(:phrase) do
      phrase.to_s
    end

    rule term_list: subtree(:term_list) do
      term_list
    end

    rule clause: subtree(:clause) do
      AST::Clause.new unary: clause[:unary], prefix: clause[:prefix], value: clause[:value]
    end

    rule negator: simple(:negator), clause: subtree(:clause) do
      AST::Negator.new value: AST::Clause.new(unary: clause[:unary], prefix: clause[:prefix], value: clause[:value])
    end

    rule and_group: subtree(:group) do
      AST::Group.new items: group, conjoiner: :and
    end

    rule or_group: subtree(:group) do
      AST::Group.new items: group, conjoiner: :or
    end

    rule expression: subtree(:expression) do
      expression
    end

    rule negator: simple(:negator), expression: subtree(:expression) do
      AST::Negator.new value: expression
    end
  end
end
