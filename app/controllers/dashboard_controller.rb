# frozen_string_literal: true

class DashboardController < ApplicationController
  require_login!

  def index
    @stats = {
      total_count: BookmarksIndex.query(
        bool: {
          must: [ { term: { user_id: current_user.id } } ]
        }
      ).count,
      untagged_count: BookmarksIndex.query(
        bool: {
          must: [ { term: { user_id: current_user.id } } ],
          must_not: [ { exists: { field: :tags } } ]
        }
      ).count
    }

    @recent_bookmarks = policy_scope(Bookmark).limit(5).page
  end
end
