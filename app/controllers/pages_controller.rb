class PagesController < ApplicationController
  require_login! only: [ :home ]

  before_action :login_redirect, only: [ :main ]

  def main
  end

  def faq
  end

  def home
    @recent_bookmarks = policy_scope(Bookmark).limit(15)
  end

  protected

  def login_redirect
    redirect_to home_path if signed_in?
  end
end
