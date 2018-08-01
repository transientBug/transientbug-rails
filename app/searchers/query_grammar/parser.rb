module QueryGrammar
  # Query Grammar Definition
  # Enables parsing something like this:
  #   "middle earth" OR earth AND (tag:computers OR +tag:rendering) AND after:2014-01-01 AND
  #   before:2018-06-14 AND NOT host:wired.com
  # Into a usable data structure that can then be transformed into a usable query AST
  #
  # EBNF Grammar:
  #      Query ::= Expression
  #
  #      Expression ::= AndExpression | OrExpression | Group | Clause
  #
  #      Group ::= Negator? '(' Space* Expression Space* ')'
  #
  #      OrExpression ::= (Clause | Group | AndExpression) (Space+ 'OR' Space+ (Clause | Group | AndExpression))+
  #
  #      AndExpression ::= (Group | OrExpression | Clause) ((Space+ 'AND')? Space+ (Group | OrExpression | Clause))+
  #
  #      Clause ::= Negator? (Prefix (( Term | TermList )?) | Term)
  #
  #      Prefix ::= Unary? Word ':'
  #
  #      Negator ::= 'NOT' Space+
  #      Unary ::= [^a-fA-F0-9]
  #
  #      TermList ::= '(' Space* (Term Space*)+ ')'
  #
  #      Term ::= Word | Phrase
  #      Phrase ::= '"' [^"]* '"'
  #
  #      Word ::= [^:")(#x9#xA#xD#x20]+
  #      Space ::= #x9 | #xA | #xD | #x20
  class Parser < Parslet::Parser
    root :query

    rule :query do
      any.absent? | expression
    end

    rule :expression do
      space? >> (infix_group | group | clause).as(:expression) >> space?
    end

    rule :group do
      negator.maybe >> str("(") >> space? >> expression >> space? >> str(")")
    end

    rule :infix_group do
      infix_expression(
        (group | clause),
        [(space >> str("OR") >> space), 2, :left],
        [((space >> str("AND")).maybe >> space), 1, :left]
      ) do |l, o, r|
        op = o.to_s.strip
        op = "AND" if op.empty?

        left_joiner = l.dig(:group, :conjoiner)
        right_joiner = r.dig(:group, :conjoiner)

        # Merge similar logic into one array rather than deeply nested
        if left_joiner == op && !right_joiner
          values = [ l[:group][:values], r ].flatten
        elsif left_joiner == op && right_joiner == op
          values = [ l[:group][:values], r[:group][:values] ].flatten
        elsif right_joiner == op && !left_joiner
          values = [ r[:group][:values], l ].flatten
        else
          values = [ l, r ]
        end

        { group: { conjoiner: op, values: values } }
      end
    end

    # #################################################################################################################
    # Base functionality
    # #################################################################################################################

    rule :clause do
      negator.maybe >> (unary.as(:unary).maybe >>
         ((prefix >> ( term | term_list ).maybe.as(:value)) |
        term.as(:value)
       )).as(:clause)
    end

    rule :prefix do
      (word.as(:term)).as(:prefix) >> str(":")
    end

    rule :negator do
      (str("NOT") >> space.repeat(1)).as(:negator).maybe
    end

    rule :unary do
      match["^[:alnum:]\":)(\s"].as(:term)
    end

    rule :term_list do
      str("(") >> space? >> (term >> space?).repeat(1).as(:term_list) >> str(")")
    end

    rule :term do
      date.as(:date) | word.as(:term) | phrase
    end

    rule :phrase do
      str('"') >> match['^"'].repeat.as(:phrase) >> str('"')
    end

    rule :word do
      match["^:\s\")("].repeat(1)
    end

    rule :date do
      digit.repeat(4) >> str("-") >> digit.repeat(2) >> str("-") >> digit.repeat(2)
    end

    rule :digit do
      match("[0-9]")
    end

    rule :space? do
      space.maybe
    end

    rule :space do
      match["\s"].repeat(1)
    end
  end
end
