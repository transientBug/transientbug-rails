# frozen_string_literal: true

class DashboardController < ApplicationController
  require_login!

  def index
    scope = policy_scope(Bookmark)

    @stats = {
      total_count: scope.count,
      untagged_count: scope.left_joins(:tags).where(bookmarks_tags: { id: nil }).count
    }

    @recent_bookmarks = scope.limit(5).page
  end
end
