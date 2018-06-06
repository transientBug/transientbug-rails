class AddBookmarksToOfflineCachesJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_join_table :bookmarks, :offline_caches
  end
end
