module QueryGrammar
  # Query Grammar Definition
  # Enables parsing something like this:
  #   "middle earth" OR earth AND (tag:computers OR +tag:rendering) AND after:2014-01-01 AND before:2018-06-14 AND NOT host:wired.com
  # Into a usable data structure that can then be transformed into a usable query AST
  #
  # EBNF Grammar:
  #      Query ::= Expression
  #
  #      Expression ::= AndExpression | OrExpression | Group | Clause
  #
  #      Group ::= Negator? '(' Space* Expression Space* ')'
  #
  #      AndExpression ::= (Clause | Group | OrExpression) (Space+ 'AND' Space+ (Clause | Group | OrExpression))+
  #
  #      OrExpression ::= (Group | AndExpression | Clause) ((Space+ 'OR')? Space+ (Group | AndExpression | Clause))+
  #
  #      Clause ::= Negator? Unary? ((Prefix ':' ( Term | TermList )?) | Term)
  #
  #      Prefix ::= Word
  #
  #      Negator ::= 'NOT' Space+
  #      Unary ::= '+' | '-'
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
      expression
    end

    rule :expression do
      and_expression | or_expression | group | clause
    end

    rule :group do
      negator.maybe >> str("(") >> space? >> expression >> space? >> str(")")
    end

    rule :and_expression do
      ((clause | group | or_expression) >>
       (space >> str("AND") >> space >>
        (clause | group | or_expression)).repeat(1)).as(:and_expression)
    end

    rule :or_expression do
      ((group | and_expression | clause) >>
       ((space >> str("OR")).maybe >> space >>
        (group | and_expression | group | clause)).repeat(1)).as(:or_expression)
    end

    ##################################

    rule :clause do
      (negator.maybe >> unary.maybe >> ((prefix >> str(":") >> ( term | term_list ).maybe) | term)).as(:clause)
    end

    rule :prefix do
      word
    end

    rule :negator do
      (str("NOT") >> space.repeat(1)).as(:negator).maybe
    end

    rule :unary do
      (str("+") | str("-")).as(:unary)
    end

    rule :term_list do
      str("(") >> space? >> (term >> space?).repeat(1).as(:term_list) >> str(")")
    end

    rule :term do
      word.as(:term) | phrase
    end

    rule :phrase do
      str('"') >> match['^"'].repeat.as(:phrase) >> str('"')
    end

    rule :word do
      match["^:\s\")("].repeat(1)
    end

    rule :space? do
      space.maybe
    end

    rule :space do
      match["\s"].repeat(1)
    end

    # rule :prefix do
    #   args = methods.select { |m| m.to_s.end_with? "_prefix" }
    #   first = send(args.first)
    #   args[1..-1].reduce(first) { |memo, arg| memo.| send(arg) }.as(:prefix)
    # end

    # def self.prefixes *args
    #   args.each do |arg|
    #     rule("#{ arg }_prefix") { str(arg) }
    #   end
    # end

    # prefixes :title, :description, :tag, :tags, :after, :before, :host, :url, :has
  end

  class Transformer < Parslet::Transform
  end
end
