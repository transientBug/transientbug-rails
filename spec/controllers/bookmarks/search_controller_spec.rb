RSpec.describe Bookmarks::SearchController do
  let(:user) { create :user }

  before do
    session[:user_id] = user.id
  end

  describe "#index" do
    skip "is this real life"
  end

  describe "#create" do
    skip "is this just fantasy"
  end

  describe "#show" do
    skip "caught in a landslide"
  end
end
