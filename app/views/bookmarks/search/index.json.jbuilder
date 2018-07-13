json.success true

json.results do
  json.array! @bookmarks, partial: "bookmarks/bookmark", as: :bookmark
end

json.action do
  json.url bookmarks_search_index_path(q: params[:q])
  json.text "See all results"
end
