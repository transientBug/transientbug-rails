class ImagesIndex < Chewy::Index
  define_type Image do
    field :title, type: "text", term_vector: "yes"
    field :tags, type: "keyword"

    field :source, type: "keyword"

    field :created_at, type: "date", include_in_all: false
  end
end
