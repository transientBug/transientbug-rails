require 'rails_helper'

RSpec.describe "admin/roles/new", type: :view do
  before(:each) do
    assign(:admin_role, Admin::Role.new())
  end

  it "renders new admin_role form" do
    render

    assert_select "form[action=?][method=?]", admin_roles_path, "post" do
    end
  end
end
