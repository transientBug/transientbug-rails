class Bookmarks::Tags::AutocompleteController < ApplicationController
  # GET /bookmarks/tags/autocomplete.json
  def index
    @tags = tags_search.take(params.fetch(:c, 5))
      .tap { |arr| arr.unshift params[:q] }
      .uniq
      .compact
      .reject(&:empty?)

    respond_to do |format|
      format.json { render :index, status: :ok }
    end
  end

  private

  def tags_search
    res = BookmarksIndex.suggest(
      "tag-suggest" => {
        text: params[:q],
        completion: {
          field: :suggest,
          fuzzy: {
            fuzziness: 2
          },
          contexts: {
            type: [ :tag ]
          }
        }
      }
    ).suggest["tag-suggest"]

    tags ||= []
    tags += res.first["options"].map { |row| row.dig("_source", "label") } if res.present?

    tags
  end
end
