json.data do
  json.array! @bookmarks, partial: 'api/v1/bookmarks/bookmark', as: :bookmark
end

json.links do
  json.self  url_to_current_page(@bookmarks)
  json.first url_to_first_page(@bookmarks)
  json.prev  url_to_prev_page(@bookmarks)
  json.next  url_to_next_page(@bookmarks)
  json.last  url_to_last_page(@bookmarks)
end

json.meta do
  json.count       @bookmarks.count
  json.total_count @bookmarks.total_count
  json.total_pages @bookmarks.total_pages
end
