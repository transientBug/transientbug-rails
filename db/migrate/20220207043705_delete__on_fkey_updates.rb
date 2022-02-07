class DeleteOnFkeyUpdates < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :offline_caches, :bookmarks
    add_foreign_key :offline_caches, :bookmarks, on_delete: :cascade
  end
end
