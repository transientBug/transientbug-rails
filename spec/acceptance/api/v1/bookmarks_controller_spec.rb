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
      explanation "Fetch the users bookmarks"

      do_request

      expect(status).to eq(200)
      expect(JSON.parse(response_body)).to be_an(Array).and(include(a_kind_of(Hash)))
    end
  end
end
