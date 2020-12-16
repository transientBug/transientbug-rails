# frozen_string_literal: true

class RelativeTimeComponent < ViewComponent::Base
  def initialize(time:)
    @time = time
  end
end
