# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::RolesController, type: :routing do
  describe "routing" do
    before do
      # rubocop:disable RSpec/AnyInstance
      allow_any_instance_of(RoleConstraint).to receive(:matches?).and_return(true)
      # rubocop:enable RSpec/AnyInstance
    end

    it "routes to #index" do
      expect(get(admin_roles_path)).to route_to(controller: "admin/roles", action: "index")
    end

    it "routes to #new" do
      expect(get: "/admin/roles/new").to route_to("admin/roles#new")
    end

    it "routes to #show" do
      expect(get: "/admin/roles/1").to route_to("admin/roles#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/admin/roles/1/edit").to route_to("admin/roles#edit", id: "1")
    end

    it "routes to #create" do
      expect(post: "/admin/roles").to route_to("admin/roles#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/admin/roles/1").to route_to("admin/roles#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/admin/roles/1").to route_to("admin/roles#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/admin/roles/1").to route_to("admin/roles#destroy", id: "1")
    end
  end
end
