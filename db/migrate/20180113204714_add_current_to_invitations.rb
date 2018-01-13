class AddCurrentToInvitations < ActiveRecord::Migration[5.2]
  def change
    add_column :invitations, :current, :integer
  end
end
