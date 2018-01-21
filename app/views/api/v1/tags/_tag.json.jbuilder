json.type "tag"
json.id tag.id

json.attributes do
  json.extract! tag, :label, :color
end

json.links do
#  json.self api_v1_tag_url(tag)
  json.view bookmarks_tags_url(tag)
end
