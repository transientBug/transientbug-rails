require 'rails_helper'

RSpec.describe "admin/roles/show", type: :view do
  before(:each) do
    @role = assign(:role, create(:role))
  end

  it "renders attributes in <p>" do
    render
  end
end
