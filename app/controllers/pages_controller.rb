class PagesController < ApplicationController
  def main
    redirect_to :dashboard if signed_in?
  end

  def faq; end

  def privacy; end

  def tos; end
end
