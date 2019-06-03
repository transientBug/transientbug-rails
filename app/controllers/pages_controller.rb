class PagesController < ApplicationController
  require_login! only: [ :home ]

  def main
    redirect_to :home if signed_in?
  end

  def faq; end

  def privacy; end

  def tos; end

  def home
    @recent_bookmarks = policy_scope(Bookmark).limit(5)
  end
end
