class MakeInvitationCodeUnique < ActiveRecord::Migration[5.2]
  def change
    add_index :invitations, :code, unique: true
  end
end
