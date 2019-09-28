require "rails_helper"

RSpec.describe "admin/roles/index", type: :view do
  let(:roles) { create_list :role, 2 }

  before do
    assign :roles, Role.all.page
  end

  it "renders a list of admin/roles" do
    render
  end
end
