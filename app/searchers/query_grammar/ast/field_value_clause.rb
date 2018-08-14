module QueryGrammar
  module AST
    class FieldValueClause < Node
      attr_reader :field, :value

      def initialize field: nil, value: nil
        @field = field
        @value = value
      end

      def to_s
        val = Array(value).map do |entry|
          next entry.to_s if entry.is_a? Date
          next "\"#{ entry }\"" if entry.index(" ")
          entry
        end.join " "

        val = "(#{ val })" if value.is_a? Array

        "#{ field }:#{ val }"
      end

      def to_h
        values = Array(value).map do |val|
          type_hash_value val
        end

        {
          self.class.name.to_s.demodulize.underscore => {
            field: field,
            values: values
          }
        }
      end

      def == other
        return false unless other.is_a? self.class
        field == other.field && value == other.value
      end
    end
  end
end
