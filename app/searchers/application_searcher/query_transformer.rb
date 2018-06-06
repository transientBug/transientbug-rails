class ApplicationSearcher
  class QueryTransformer < Parslet::Transform
    rule(clause: subtree(:clause)) do
      operator = clause[:operator]&.to_s
      field = clause[:field]&.to_s

      if clause[:phrase]
        PhraseClause.new operator, field, clause[:phrase]
      else
        TermClause.new operator, field, clause[:term]
      end
    end

    rule(query: sequence(:clauses)) { Query.new(clauses) }
  end
end
