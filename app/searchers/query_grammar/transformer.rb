# frozen_string_literal: true

module QueryGrammar
  class Transformer < Parslet::Transform
    attr_reader :index

    def initialize(index, *args, &)
      super(*args, &)

      @index = index
    end

    # Override this from parslet to allow binding the block to the transform
    # instance, so that rules can work with the instances index
    def call_on_match bindings, block
      return unless block

      return Cloaker.new(bind: self).cloak(bindings, &block) if block.arity == 1

      Cloaker.new(bind: Context.new(bindings)).cloak(&block)
    end

    def parse_clause subtree_clause
      values = Array(subtree_clause[:value])
      base_clause = OpenStruct.new subtree_clause.merge(values:)

      fields = index.resolve_field base_clause.prefix
      fields ||= index.default_fields

      inner = Array(fields).map do |field|
        clause = base_clause.dup.tap do |obj|
          obj[:prefix] = field
        end

        field_data = index.fields[ field ]&.parse
        field_data ||= index.operators[ field ]&.parse
        field_data ||= index.fallback

        # debugger if not field_data

        Cloaker.new(bind: index).cloak(clause, &field_data)
      end.flatten

      return inner.first if inner.length == 1

      QueryGrammar::Ast::Group.new joiner: :or, items: inner, origin: subtree_clause
    end

    rule term: simple(:term) do
      term.to_s
    end

    rule date: simple(:date) do
      Date.strptime date, "%Y-%m-%d"
    end

    rule phrase: simple(:phrase) do
      phrase.to_s
    end

    rule term_list: subtree(:term_list) do
      term_list
    end

    rule clause: subtree(:clause) do |subtree|
      parse_clause subtree[:clause]
    end

    rule negator: simple(:negator), clause: subtree(:clause) do |subtree|
      inner = parse_clause subtree[:clause]

      QueryGrammar::Ast::Negator.new items: inner, origin: subtree
    end

    rule group: subtree(:group) do |subtree|
      group = subtree[:group]

      QueryGrammar::Ast::Group.new items: group[:values], joiner: group[:joiner].downcase.to_sym, origin: subtree
    end

    rule expression: subtree(:expression) do
      expression
    end

    rule negator: simple(:negator), expression: subtree(:expression) do |subtree|
      QueryGrammar::Ast::Negator.new items: subtree[:expression], origin: subtree
    end
  end
end
