require "rails_helper"

RSpec.describe "admin/roles/show", type: :view do
  let(:role) { create :role }

  before do
    assign :role, role
  end

  it "renders attributes" do
    render
  end
end
