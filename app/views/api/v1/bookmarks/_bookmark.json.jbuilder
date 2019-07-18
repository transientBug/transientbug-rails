json.type "bookmark"
json.id bookmark.id

json.attributes do
  json.extract! bookmark, :title, :description, :created_at, :updated_at
  json.uri bookmark.uri.to_s
  json.url bookmark.uri.to_s

  json.tags bookmark.tags.map(&:label)
end

json.links do
  json.self api_v1_bookmark_url(bookmark)
  json.view bookmark_url(bookmark)
end
