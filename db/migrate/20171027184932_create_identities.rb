class CreateIdentities < ActiveRecord::Migration[5.2]
  def change
    create_table :identities do |t|
      t.references :user, foreign_key: true
      t.text :email
      t.text :name
      t.text :password_digest

      t.timestamps
    end
  end
end
