# frozen_string_literal: true

require "rails_helper"

RSpec.describe "admin/roles/edit", type: :view do
  let(:role) { create :role }

  before do
    assign :role, role
  end

  it "renders the edit role form" do
    render

    assert_select "form[action=?][method=?]", admin_role_path(role), "post" do
    end
  end
end
