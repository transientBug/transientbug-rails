class AddAuthTokenToUsers < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :auth_token, :text
    add_index :users, :auth_token, unique: true

    User.all.each { |user| user.regenerate_auth_token }
  end

  def down
    remove_column :users, :auth_token
  end
end
