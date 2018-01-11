json.success true
json.results do
  json.bookmarks do
    json.name "Bookmarks"
    json.results do
      json.array! @bookmarks, partial: "bookmarks/bookmark", as: :bookmark
    end
  end

  json.tags do
    json.name "Tags"
    json.results do
      json.array! @tags, partial: "bookmarks/tag", as: :tag
    end
  end
end
json.action do
  json.url search_bookmarks_path(q: params[:q])
  json.text "See all results"
end