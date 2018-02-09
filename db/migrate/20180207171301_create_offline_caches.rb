class CreateOfflineCaches < ActiveRecord::Migration[5.2]
  def change
    create_table :offline_caches do |t|
      t.references :webpage, foreign_key: true
      t.references :root, foreign_key: { to_table: :active_storage_attachments }, null: true

      t.timestamps
    end
  end
end
