class ConsolidateBookmarksOnOfflineCaches < ActiveRecord::Migration[7.0]
  def change
    add_reference :offline_caches, :bookmark, foreign_key: true
  end
end
