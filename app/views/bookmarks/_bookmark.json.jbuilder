json.extract! bookmark, :id, :title, :description, :tags, :uri_string, :created_at, :updated_at
json.view bookmark_url(bookmark)
json.url bookmark_url(bookmark, format: :json)
