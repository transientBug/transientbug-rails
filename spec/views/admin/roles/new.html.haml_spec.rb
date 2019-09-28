require "rails_helper"

RSpec.describe "admin/roles/new", type: :view do
  before do
    assign(:role, build(:role))
  end

  it "renders new role form" do
    render

    assert_select "form[action=?][method=?]", admin_roles_path, "post"
  end
end
