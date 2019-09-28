require "rails_helper"

RSpec.describe "admin/roles/index", type: :view do
  before do
    create_list(:role, 2)

    assign(:roles, Role.all.page)
  end

  it "renders a list of admin/roles" do
    render
  end
end
