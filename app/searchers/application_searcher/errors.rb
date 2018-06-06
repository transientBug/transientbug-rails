class ApplicationSearcher
  # Basic extension of a hash the provides a basic ActiveModel::Errors like
  # interface which remaining serializable and easy to work with.
  class Errors < Hash
    def add key, value
      self[key] ||= []
      self[key] << value
      self[key].uniq!
    end

    def each
      each_key do |field|
        self[field].each { |message| yield field, message }
      end
    end
  end
end
