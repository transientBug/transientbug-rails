class CreateInvitations < ActiveRecord::Migration[5.2]
  def change
    create_table :invitations do |t|
      t.text :code
      t.text :internal_note
      t.text :title
      t.text :description
      t.integer :limit
      t.integer :available

      t.timestamps
    end
  end
end
