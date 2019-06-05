RSpec.resource "v1 Profile" do
  let(:user) { create(:user) }
  let(:auth_token) { "#{ user.email }:#{ user.api_token }" }

  header "Content-Type", "application/vnd.api+json"
  header "Accept", "application/vnd.api+json"

  parameter :auth_token, "Authentication Token", required: true

  # rubocop:disable RSpec/ExampleLength
  get "/api/v1/profile" do
    example "Get" do
      explanation <<~DESC
        Fetch the users profile information, including their api_token and email used to build the auth_token.
      DESC

      do_request

      expect(status).to eq(200)
      expect(response_body).to match_response_schema("api/v1/profiles/profile")
    end
  end
  # rubocop:enable RSpec/ExampleLength
end
