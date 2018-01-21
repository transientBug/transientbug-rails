json.type "bookmark"
json.id bookmark.id

json.attributes do
  json.extract! bookmark, :title, :created_at, :updated_at
  json.uri bookmark.uri_string
  json.attr! bookmark.tags, partial: 'api/v1/tags/tag', as: :tag
end

json.links do
  json.self api_v1_bookmark_url(bookmark)
  json.view bookmark_url(bookmark)
end
