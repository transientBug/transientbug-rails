json.extract! image, :id, :title, :tags, :source, :created_at, :updated_at
json.image image_url(image, format: :gif)
json.view image_url(image)
json.url image_url(image, format: :json)
