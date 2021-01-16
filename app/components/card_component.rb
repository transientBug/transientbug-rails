# frozen_string_literal: true

class CardComponent < ViewComponent::Base
  with_content_areas :header, :body, :footer

  # include ViewComponent::SlotableV2

  # renders_one :header
  # renders_one :content
  # renders_one :footer
end
