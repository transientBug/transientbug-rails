require 'rails_helper'

RSpec.describe "admin/roles/edit", type: :view do
  before(:each) do
    @admin_role = assign(:admin_role, Admin::Role.create!())
  end

  it "renders the edit admin_role form" do
    render

    assert_select "form[action=?][method=?]", admin_role_path(@admin_role), "post" do
    end
  end
end
