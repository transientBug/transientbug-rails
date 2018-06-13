class ApplicationSearcher
  class Clause
    OP_MAP = {
      "+" => :must,
      "-" => :must_not,
      nil => :should
    }.freeze

    attr_accessor :op, :operator, :field, :term

    def initialize operator, field
      @op = operator
      @operator = OP_MAP[ operator ].tap do |op_symbol|
        fail ArgumentError, "Unknown operator: `#{ operator }'" unless op_symbol
      end

      @field = field&.to_sym
    end

    def blank?
      fail NotImplementedError
    end
  end
end
