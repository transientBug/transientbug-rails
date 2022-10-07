# frozen_string_literal: true

class Admin::HomeController < AdminController
  # GET /admin
  def home
    @bookmarks_count = Bookmark.count
    @bookmarks_7days_ago_count = Bookmark.where(Bookmark.arel_table[:created_at].lt(7.days.ago)).count

    @users_count = User.count
    @users_7days_ago_count = User.where(User.arel_table[:created_at].lt(7.days.ago)).count
  end

  def logs; end
  def workers; end
end
