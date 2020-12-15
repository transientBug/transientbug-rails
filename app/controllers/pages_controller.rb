# frozen_string_literal: true

class PagesController < ApplicationController
  layout "page"

  def main
    layout "blank"
    redirect_to :home if signed_in?
  end

  def faq; end

  def privacy; end

  def tos; end
end
