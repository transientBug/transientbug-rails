json.data do
  json.array! @bookmarks, partial: 'api/v1/bookmarks/bookmark', as: :bookmark
end

json.links do
  json.first
  json.previous
  json.next
  json.last
end
