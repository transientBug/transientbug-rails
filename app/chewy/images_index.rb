class ImagesIndex < Chewy::Index
  METHODS = [:itself, :downcase, :capitalize, :titleize].freeze

  TagStruct = Struct.new(:id, :tag) do
    def self.from tag
      new tag, tag
    end
  end

  define_type Image do
    field :title, type: "text", term_vector: "yes"
    field :tags, type: "keyword"

    field :suggest, type: "completion", contexts: [ { name: :type, type: :category } ], value: ->(image) {
      tags = image.tags.flat_map do |tag|
        METHODS.map(&tag.method(:public_send))
      end

      {
        input: METHODS.map(&image.title.method(:public_send)).concat(tags).uniq,
        contexts: {
          type: [:image]
        }
      }
    }

    field :source, type: "keyword"

    field :created_at, type: "date", include_in_all: false
  end

  def self.numbered_tags
    ActiveRecord::Base.connection.execute("SELECT DISTINCT UNNEST(tags) AS tag FROM images").to_a
      .map { |row| TagStruct.from row["tag"] }
  end

  define_type -> { numbered_tags }, name: :tag do
    field :tag, type: "keyword", value: ->(tag_struct) { tag_struct.tag }
    field :suggest, type: "completion", contexts: [ { name: :type, type: :category } ], value: ->(tag_struct) {
      {
        input: METHODS.map(&tag_struct.tag.method(:public_send)).uniq,
        contexts: {
          type: [:tag]
        }
      }
    }
  end
end
