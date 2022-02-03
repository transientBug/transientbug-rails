# frozen_string_literal: true

class StatsComponent < ViewComponent::Base
  include ViewComponent::SlotableV2

  def initialize title: nil
    @title = title
  end

  renders_many :stats, "StatComponent"

  class StatComponent < ViewComponent::Base
    def initialize title:, number:
      @title = title
      @number = number
    end
  end
end
