resource "Profiles" do
  let(:user) { create(:user) }
  let(:auth_token) { "#{ user.email }:#{ user.api_token }" }

  parameter :auth_token, "Authentication Token", required: true

  get "/api/v1/profile" do
    let(:expected_body) { { profile: { api_token: user.api_token } } }

    example "Get" do
      explanation "Fetch the users auth_token"

      do_request

      expect(status).to eq(200)
      expect(response_body).to eq(expected_body.to_json)
    end
  end
end
