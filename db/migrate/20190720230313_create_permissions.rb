class CreatePermissions < ActiveRecord::Migration[5.2]
  def change
    create_table :permissions do |t|
      t.references :role, foreign_key: true

      t.string :key

      t.string :name
      t.string :description

      t.timestamps
    end

    add_index :permissions, :key, unique: true
  end
end
