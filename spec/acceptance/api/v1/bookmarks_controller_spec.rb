resource "Bookmarks" do
  let(:user) { create(:user) }
  let(:auth_token) { "#{ user.email }:#{ user.api_token }" }

  let(:bookmark) { create(:bookmark_with_tags, user: user) }

  before do
    bookmark
  end

  header "Content-Type", "application/json"

  parameter :auth_token, "Authentication Token", required: true

  get "/api/v1/bookmarks" do
    example "Get" do
      explanation "Fetch the users bookmarks."

      do_request

      expect(status).to eq(200)
      expect(response_body).to match_response_schema("api/v1/bookmarks/index")
    end
  end

  get "/api/v1/bookmarks/:id" do
    let(:id) { bookmark.id }

    example "Get" do
      explanation "Fetch a users specific bookmark."

      do_request

      expect(status).to eq(200)
      expect(response_body).to match_response_schema("api/v1/bookmarks/show")
    end
  end
end
