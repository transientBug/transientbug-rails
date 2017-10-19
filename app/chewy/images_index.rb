class ImagesIndex < Chewy::Index
  define_type Image do
    field :title, type: "text", term_vector: "yes"
    field :tags, type: "keyword"

    field :suggest, type: "completion", value: ->(image) {
      {
        input: [
          image.title.downcase,
          image.title.capitalize,
          image.title.titleize
        ].uniq
      }
    }

    field :source, type: "keyword"

    field :created_at, type: "date", include_in_all: false
  end

  TagStruct = Struct.new(:id, :tag) do
    def self.from tag
      new tag, tag
    end
  end

  def self.numbered_tags
    ActiveRecord::Base.connection.execute("SELECT DISTINCT UNNEST(tags) AS tag FROM images").to_a
      .map { |row| TagStruct.from row["tag"] }
  end

  define_type -> { numbered_tags }, name: :tag do
    field :tag, type: "keyword", value: ->(tag_struct) { tag_struct.tag }
    field :suggest, type: "completion", value: ->(tag_struct) {
      {
        input: [
          tag_struct.tag,
          tag_struct.tag.capitalize,
          tag_struct.tag.downcase
        ].uniq
      }
    }
  end
end
