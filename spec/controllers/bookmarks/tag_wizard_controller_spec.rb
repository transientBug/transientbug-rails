# frozen_string_literal: true

require "rails_helper"

RSpec.describe Bookmarks::TagWizardController, type: :controller do
  let(:valid_attributes) do
    {
      tags: "test"
    }
  end

  let(:user) { create :user, :with_permissions, permissions: [] }

  let(:valid_session) do
    {
      user_id: user.id
    }
  end

  let(:bookmark) { create :bookmark, tags: [], user_id: user.id }

  before do
    bookmark
  end

  describe "GET #index" do
    it "returns http success" do
      get :index, session: valid_session

      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #update" do
    it "returns http success" do
      post :update, params: { id: bookmark.id, bookmark: valid_attributes }, session: valid_session

      expect(response).to redirect_to(bookmarks_tag_wizard_index_path)
    end
  end
end
