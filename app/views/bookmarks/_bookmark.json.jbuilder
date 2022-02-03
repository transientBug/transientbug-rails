json.extract! bookmark, :id, :title, :description, :created_at, :updated_at
json.uri bookmark.uri.to_s

json.tags do
  json.array! bookmark.tags, partial: "tags/tag", as: :tag
end

json.url bookmark_url(bookmark, format: :json)
json.view bookmark_url(bookmark)
