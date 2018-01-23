resource "v1 Bookmarks" do
  let(:user) { create(:user) }
  let(:auth_token) { "#{ user.email }:#{ user.api_token }" }

  let(:bookmark) { create(:bookmark_with_tags, user: user) }

  header "Content-Type", "application/vnd.api+json"
  header "Accept", "application/vnd.api+json"

  parameter :auth_token, "Authentication Token", required: true

  get "/api/v1/bookmarks" do
    before do
      bookmark
    end

    example "Get All Bookmarks" do
      do_request

      expect(status).to eq(200)
      expect(response_body).to match_response_schema("api/v1/bookmarks/index")
    end
  end

  post "/api/v1/bookmarks" do
    with_options scope: :data do
      parameter :type, "bookmark", required: true
    end

    with_options scope: [ :data, :attributes ] do
      parameter :url, "Bookmarks URL", required: true
      parameter :title, "Title", required: true
      parameter :description, "Description/Note"
      parameter :tags, "Comma separated"
    end

    let(:type) { "bookmark" }
    let(:url) { "https://bookmark.example" }
    let(:title) { "bookmark 1" }
    let(:description) { "Something witty" }
    let(:tags) { "tag 1, tag 2, tag 3" }

    let(:raw_post) { params.to_json }

    example "Upsert a Bookmark" do
      do_request

      expect(status).to eq(201)
      expect(response_body).to match_response_schema("api/v1/bookmarks/show")
    end
  end

  get "/api/v1/bookmarks/:id" do
    before do
      bookmark
    end

    let(:id) { bookmark.id }

    parameter :id, "Bookmark ID", required: true

    example "Get a Bookmark" do
      do_request

      expect(status).to eq(200)
      expect(response_body).to match_response_schema("api/v1/bookmarks/show")
    end
  end

  patch "/api/v1/bookmarks/:id" do
    with_options scope: :data do
      parameter :type, "bookmark", required: true
      parameter :id, "Bookmark ID to update", required: true
    end

    with_options scope: [ :data, :attributes ] do
      parameter :url, "Bookmarks URL", required: true
      parameter :title, "Title", required: true
      parameter :description, "Description/Note"
      parameter :tags, "Comma separated"
    end

    let(:type) { "bookmark" }
    let(:id) { bookmark.id }
    let(:url) { "https://bookmark.example" }
    let(:title) { "bookmark 1" }
    let(:description) { "Something witty" }
    let(:tags) { "tag 1, tag 2, tag 3" }

    let(:raw_post) { params.to_json }

    example "Update a Bookmark" do
      do_request

      expect(status).to eq(200)
      expect(response_body).to match_response_schema("api/v1/bookmarks/show")
    end
  end

  delete "/api/v1/bookmarks/:id" do
    let(:id) { bookmark.id }

    example "Delete a bookmark" do
      do_request

      expect(status).to eq(204)
    end
  end

  get "/api/v1/bookmarks/check", focus: true do
    parameter :url, "URL to check", required: true

    let(:url) { bookmark.uri_string }

    example "Check for an existing bookmark" do
      do_request

      expect(status).to eq(302)
    end
  end

  get "/api/v1/bookmarks/check" do
    parameter :url, "URL to check", required: true

    let(:url) { "http://not.found" }

    example "Check for a non-existent bookmark" do
      do_request

      expect(status).to eq(404)
    end
  end
end
