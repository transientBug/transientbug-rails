# frozen_string_literal: true

require "rails_helper"

# https://relishapp.com/rspec/rspec-rails/docs/request-specs/request-spec
RSpec.describe "Admin::Roles management", type: :request do
  let(:user) { create :user, :with_permissions, permissions: [] }

  before do
    # rubocop:disable RSpec/AnyInstance
    allow_any_instance_of(PermissionConstraint).to receive(:matches?).and_return(true)
    allow_any_instance_of(AdminController).to receive(:current_user).and_return(user)
    # rubocop:enable RSpec/AnyInstance
  end

  it "creates a new role and redirects to its page" do
    post admin_roles_path, params: { role: { name: "test" } }

    expect(response).to redirect_to([:admin, Role.last])
  end

  it "redirects successfully" do
    post admin_roles_path, params: { role: { name: "test" } }
    follow_redirect!

    expect(response).to be_successful
  end
end
