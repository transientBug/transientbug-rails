RSpec.describe Bookmarks::SearchController do
  let(:user) { create :user }

  before do
    session[:user_id] = user.id
  end

  describe "#index" do
  end

  describe "#create" do
  end

  describe "#show" do
  end
end
