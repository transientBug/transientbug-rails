class AddPermissionKeysToRoles < ActiveRecord::Migration[6.0]
  def change
    add_column :roles, :permission_keys, :string, array: true, default: "{}", null: false

    reversible do |dir|
      Role.reset_column_information

      dir.up do
        Role.upsert_all [
          { name: "admin", permission_keys: ["admin.access"], created_at: Time.now, updated_at: Time.now },
          { name: "user", permission_keys: [], created_at: Time.now, updated_at: Time.now }
        ], unique_by: :name
      end
    end
  end
end
