class DropPermissionsTable < ActiveRecord::Migration[6.0]
  def change
    drop_table :permissions_roles
    drop_table :permissions
  end
end
