class RemoveLimitAndCurrentFromInvitations < ActiveRecord::Migration[5.2]
  def change
    remove_column :invitations, :limit
    remove_column :invitations, :current
  end
end
