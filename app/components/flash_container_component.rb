# frozen_string_literal: true

class FlashContainerComponent < ViewComponent::Base
  def initialize(flash:)
    @flash = flash
  end

  def types()= [ :notice, :alert ]
end
