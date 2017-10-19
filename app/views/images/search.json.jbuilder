json.success true
json.results do
  json.images do
    json.name "Images"
    json.results do
      json.array! @images, partial: "images/image", as: :image
    end
  end

  json.tags do
    json.name "Tags"
    json.results do
      json.array! @tags, partial: "images/tag", as: :tag
    end
  end
end
