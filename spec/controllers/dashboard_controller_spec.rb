require "rails_helper"

RSpec.describe DashboardController, type: :controller do
  describe "GET #index" do
    let(:user) { create :user }

    before do
      session[:user_id] = user.id
    end

    it "returns http success" do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end
end
