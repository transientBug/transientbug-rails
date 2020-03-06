class DropAuthorizationsTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :authorizations
  end
end
