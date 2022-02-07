# frozen_string_literal: true

class CardComponent < ViewComponent::Base
  renders_one :header
  renders_one :body
  renders_one :footer
end
