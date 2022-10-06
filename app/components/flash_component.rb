# frozen_string_literal: true

class FlashComponent < ViewComponent::Base
  TYPES = {
    notice: "bg-denim-400",
    alert: "bg-mango-700",
  }.freeze

  attr_reader :message

  def initialize(message:, type:)
    fail "Invalid flash type `#{ type }'" unless TYPES.key? type

    @message = message
    @type = type
  end

  def color_class()= TYPES[@type]

  def render?()= message.present?
end
