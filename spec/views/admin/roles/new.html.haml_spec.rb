require "rails_helper"

RSpec.describe "admin/roles/new", type: :view do
  let(:role) { build :role }

  before do
    assign :role, role
  end

  it "renders new role form" do
    render

    assert_select "form[action=?][method=?]", admin_roles_path, "post"
  end
end
