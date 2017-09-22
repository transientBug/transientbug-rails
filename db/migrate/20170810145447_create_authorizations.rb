class CreateAuthorizations < ActiveRecord::Migration[5.1]
  def change
    create_table :authorizations do |t|
      t.references :user, foreign_key: true, null: false

      t.string :provider
      t.string :uid

      t.string :name
      t.string :nickname
      t.string :email
      t.string :image

      t.string :token
      t.string :secret
      t.boolean :expires
      t.timestamp :expires_at

      t.timestamps
    end
  end
end
