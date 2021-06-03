# frozen_string_literal: true

class PagesController < ApplicationController
  layout "page"

  def main
    return redirect_to :home if signed_in?

    render :main, layout: "blank"
  end

  def faq; end

  def privacy; end

  def tos; end
end
