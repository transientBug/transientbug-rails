json.success true

json.results do
  json.array! @tags, partial: "bookmarks/tags/tag", as: :tag
end
