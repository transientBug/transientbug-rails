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
        ]
      }
    }

    field :source, type: "keyword"

    field :created_at, type: "date", include_in_all: false
  end

  define_type -> { ActiveRecord::Base.connection.execute("SELECT DISTINCT UNNEST(tags) FROM images").to_a.map { |row| row["unnest"] } }, name: :tag do
    field :tag, type: "keyword", value: ->(tag) { tag }
    field :suggest, type: "completion", value: ->(tag) {
      {
        input: [ tag.capitalize, tag.downcase ]
      }
    }
  end
end
