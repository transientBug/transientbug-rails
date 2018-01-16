class RolesToUsersJoinTable < ActiveRecord::Migration[5.2]
  def change
    create_join_table :roles, :users

    roles = [
      :admin,
      :user
    ].map do |role|
      Role.create name: role
    end

    User.find_by(email: Rails.application.credentials.admin_email)&.roles = roles
  end
end
