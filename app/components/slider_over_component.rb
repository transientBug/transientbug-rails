# frozen_string_literal: true

class SliderOverComponent < ViewComponent::Base
  renders_one :body

  attr_reader :title, :subtitle

  def initialize(title:, subtitle: nil)
    @title = title
    @subtitle = subtitle
  end

  def has_subtitle?()= @subtitle.present?
end
