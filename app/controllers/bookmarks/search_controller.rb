class Bookmarks::SearchController < ApplicationController
  # GET /bookmarks/search
  # GET /bookmarks/search.json
  def index
    @bookmarks = BookmarksIndex.query(
      bool: {
        should: [
          { match: { title: params[:q] } },
          { match: { tags: params[:q] } }
        ]
      }
    ).objects.page params[:page]

    respond_to do |format|
      format.html { render :index }
      format.json { render :index, status: :ok }
    end
  end

  def create
    binding.pry
  end

  protected

  helper_method :query_builder_config

  def query_builder_config
    {
      fields: {
        user_id: { type: :number, display_name: "User ID", description: "" },
        uri: { type: :keyword, display_name: "URI", description: "", exclude_operations: [ "exist" ] },
        host: { type: :keyword, display_name: "Host", description: "", exclude_operations: [ "exist" ] },
        title: { type: :text, display_name: "Title", description: "" },
        description: { type: :text, display_name: "Description", description: "" },
        tags: { type: :keyword, display_name: "Tags", description: "" },
        created_at: { type: :date, display_name: "Created At Date", description: "", exclude_operations: [ "exist" ] }
      },
      config: {
        operations: {
          "[between]": { display_name: "After til Before", description: "", parameters: 2 },
          "[between)": { display_name: "After til Before or On", description: "", parameters: 2 },
          "(between]": { display_name: "On or After til Before", description: "", parameters: 2 },
          "(between)": { display_name: "On or After til Before or On", description: "", parameters: 2 },
          "less_than": { display_name: "Less Than", description: "" },
          "less_than_or_equal": { display_name: "Less Than or Equal", description: "" },
          "equal": { display_name: "Equals", description: "" },
          "greater_than_or_equal": { display_name: "Greater Than or Equal", description: "" },
          "greater_than": { display_name: "Greater Than", description: "" },
          "match": { display_name: "Matches", description: "" },
          "exist": { display_name: "Exists", description: "", parameters: 0 }
        },
        types: {
          text: {
            supported_operations: [ "match", "exist" ],
            default_operation: "match"
          },
          keyword: {
            supported_operations: [ "equal", "exist" ],
            default_operation: "equal"
          },
          number: {
            supported_operations: [ "[between]", "[between)", "(between]", "(between)", "less_than", "less_than_or_equal", "equal", "greater_than_or_equal", "greater_than", "exist" ],
            default_operation: "equal"
          },
          date: {
            supported_operations: [ "[between]", "[between)", "(between]", "(between)", "less_than", "less_than_or_equal", "equal", "greater_than_or_equal", "greater_than", "exist" ],
            default_operation: "equal"
          },
        },
        joiners: {
          should: { display_name: "Or", description: "" },
          must: { display_name: "And", description: "" },
          must_not: { display_name: "Not", description: "" }
        }
      },
      meta: {
        url: bookmarks_search_index_path
      },
      query: {
        id: 0,
        should: [
          { id: 1, field: "title", operation: "match", values: ["earth"] },
          { id: 2, field: "description", operation: "match", values: ["earth"] }
        ],
        must: [
          { id: 3, field: "tags", operation: "equal", values: ["computers"] },
          {
            id: 4,
            must: [
              { id: 7, field: "title", operation: "exist" },
              { id: 5, field: "created_at", operation: "[between]", values: ["2014-01-01", "2018-06-14"] },
            ]
          }
        ],
        must_not: [
          { id: 6, field: "host", operation: "equal", values: ["wired.com"] }
        ]
      }
    }
  end

  def query_builder_to_elasticsearch query_builder
  end
end
