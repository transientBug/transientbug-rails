json.extract! bookmark, :id, :title, :description, :uri_string, :created_at, :updated_at
json.tags do
  json.array! bookmark.tags, partial: "bookmarks/tags/tag", as: :tag
end

json.url bookmark_url(bookmark, format: :json)
json.view bookmark_url(bookmark)
