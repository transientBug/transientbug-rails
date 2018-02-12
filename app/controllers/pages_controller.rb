class PagesController < ApplicationController
  require_login! only: [ :home ]

  def main; end

  def faq; end

  def privacy; end

  def tos; end

  def home
    @recent_bookmarks = policy_scope(Bookmark).limit(15)
  end
end
