class CreateRoles < ActiveRecord::Migration[5.2]
  def change
    create_table :roles do |t|
      t.text :name, null: false

      t.timestamps
    end

    add_index :roles, :name, unique: true
  end
end
