class AddErrorMessagesToOfflineCachesJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_join_table :offline_caches, :error_messages
  end
end
