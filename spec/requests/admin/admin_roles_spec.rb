require 'rails_helper'

# https://relishapp.com/rspec/rspec-rails/docs/request-specs/request-spec
RSpec.describe "Admin::Roles management", type: :request do
  before do
    allow_any_instance_of(RoleConstraint).to receive(:matches?).and_return(true)
  end

  it "creates a new role and redirects to its page" do
    skip "Requires a gem and i'm working offline"

    get new_admin_role_path
    expect(response).to render_template(:new)

    post admin_roles_path, params: { role: { name: "test" } }

    expect(response).to redirect_to(assigns(:role))
    follow_redirect!

    expect(response).to render_template(:show)
    expect(response.body).to include("Role was successfully created.")
  end
end
