class SetDefaultAvailableOnInvitations < ActiveRecord::Migration[5.2]
  def change
    change_column_default :invitations, :available, 1
  end
end
