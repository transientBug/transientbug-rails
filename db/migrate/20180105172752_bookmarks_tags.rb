class BookmarksTags < ActiveRecord::Migration[5.2]
  def change
    create_join_table :bookmarks, :tags
  end
end
