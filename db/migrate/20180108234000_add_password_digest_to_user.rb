class AddPasswordDigestToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :password_digest, :string

    User.connection.execute "UPDATE users SET password_digest = identities.password_digest FROM identities WHERE users.id = identities.user_id"
  end
end
