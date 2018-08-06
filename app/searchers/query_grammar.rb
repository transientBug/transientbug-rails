module QueryGrammar
  Error          = Class.new StandardError
  ParseError     = Class.new Error
  CompileError   = Class.new Error

  autoload :AST, "query_grammar/ast"
  autoload :Parser, "query_grammar/parser"
  autoload :Transformer, "query_grammar/transformer"
  autoload :Compiler, "query_grammar/compiler"

  def self.rehydrate json
    parsed_json = json.is_a?(String) ? JSON.parse(json) : json
    QueryGrammar::JSONHydrator.new.apply parsed_json.deep_symbolize_keys
  end

  def self.parse input
    QueryGrammar::Transformer.new.apply QueryGrammar::Parser.new.parse(input.strip)
  rescue Parslet::ParseFailed => e
    deepest = deepest_cause e.parse_failure_cause
    line, column = deepest.source.line_and_column deepest.pos

    # TODO: Make this fail with a more informative error rather than just a
    # message. An object with a reference to the Parslet error and info such as
    # the column and line for highlighting in the UI
    fail ParseError, "unexpected input at line #{line} column #{column} - #{deepest.message} #{input[column-1..-1]}"
  rescue SystemStackError => e
    fail ParseError, "unexpected input at line 1 column 1 - #{e}: #{input}"
  end

  def self.deepest_cause cause, depth=0
    # puts "#{ " |"*depth } ^"
    # puts "#{ " |"*depth } |---> At depth #{ depth } with #{ cause.children.length } children"

    if cause.children.any?
      causes = cause.children.map { |xcause| deepest_cause xcause, depth+1 }
      cause = causes.max { |xcause, other| xcause.pos.bytepos <=> other.pos.bytepos }

      # puts "#{ " |"*depth }---= Found #{ cause.pos.bytepos } pos"
      cause
    else
      # puts "#{ " |"*depth }---$ Found #{ cause.pos.bytepos } pos"
      cause
    end
  end

  class Visitor
    def self.visitors
      @visitors ||= {}
    end

    def self.on type, **opts, &block
      matcher = lambda do |*data|
        opts.all? { |k, v| matchers[ type ][k].call v, *data }
      end

      visitors[ type ] ||= []
      visitors[ type ].push({ opt_length: opts.keys.length, matcher: matcher, block: block })
      visitors[ type ].sort_by! { |a| a[:opt_length] }.reverse!
    end

    def self.matchers
      @matchers ||= {}
    end

    def self.def_matcher type, key, &block
      matchers[ type ] ||= {}
      matchers[ type ][ key ] = block
    end

    def visitors
      self.class.visitors
    end

    def finalize
      fail NotImplementedError
    end

    def method_missing func, *args
      str_name = func.to_s
      return super(func, *args) unless str_name.start_with? "visit_"

      name = str_name.gsub(/^visit_/, "").to_sym

      if visitors.key? name
        visitor = visitors[ name ].find { |v| v[:matcher].call(*args) }
        return QueryGrammar::Compiler::Cloaker.new(bind: self).cloak(*args, &visitor[:block])
      end
    end
  end

  class EchoVisitor < Visitor
    def stack
      @stack ||= []
    end

    def finalize
      stack.first
    end

    def_matcher :clause, :prefix do |input, clause|
      clause.prefix == input
    end

    def_matcher :clause, :type do |input, clause|
      types = Array(input)

      clause.values.all? do |v|
        types.any? { |t| v.is_a? t }
      end
    end

    def_matcher :clause, :arity do |input, clause|
      clause.values.length <= input
    end

    on :any do |node|
      puts "ANY #{ node }"
    end

    on :negator do |negator|
      puts "NOT #{ negator }"

      stack.push "NOT " + stack.pop
    end

    on :group do |group|
      puts "GROUP #{ group.conjoiner } #{ group }"

      items = group.items.length.times.map { stack.pop }
      stack.push "(" + items.reverse.join(" #{ group.conjoiner.to_s.upcase } ") + ")"
    end

    on :clause do |clause|
      puts "CLAUSE #{ clause }"

      stack.push clause.to_s
    end

    on :value_list do |values, clause|
      puts "VALUE LIST #{ values.length } #{ clause }"
    end

    on :value_date do |date, clause|
      puts "VALUE DATE #{ date } #{ clause }"
    end

    on :value_phrase do |phrase, clause|
      puts "VALUE PHRASE #{ phrase } #{ clause }"
    end

    on :value do |value, clause|
      puts "VALUE #{ value } #{ clause }"
    end

    on :prefix do |prefix, clause|
      puts "PREFIX #{ prefix } #{ clause }"
    end

    on :unary do |unary, clause|
      puts "UNARY #{ unary } #{ clause }"
    end

    on :clause, prefix: "after", type: Date, arity: 1 do |clause|
      puts "AFTER PREFIX CLAUSE #{ clause }"
    end
  end
end
