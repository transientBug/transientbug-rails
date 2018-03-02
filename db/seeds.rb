# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

roles = [
  :admin,
  :user
].map do |role|
  Role.create name: role
end

me = User.create(
  username: "ashby",
  email: Rails.application.credentials.admin_email,
  password: Rails.application.credentials.admin_password,
  password_confirmation: Rails.application.credentials.admin_password,
  roles: roles
)
