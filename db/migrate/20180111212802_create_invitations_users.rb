class CreateInvitationsUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :invitations_users do |t|
      t.references :invitation, foreign_key: true, null: false
      t.references :users, foreign_key: true, null: true, unique: true

      t.timestamps
    end
  end
end
