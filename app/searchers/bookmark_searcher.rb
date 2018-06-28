class BookmarkSearcher < ApplicationSearcher
  index BookmarksIndex::Bookmark
  model Bookmark

  keyword :uri
  keyword :host

  keyword :title
  keyword :description

  keyword :tags, aliases: [ :tag ]
end
