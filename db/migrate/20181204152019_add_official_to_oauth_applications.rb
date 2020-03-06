class AddOfficialToOauthApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :oauth_applications, :official, :boolean, default: false
  end
end
