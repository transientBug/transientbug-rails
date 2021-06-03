# frozen_string_literal: true

class Admin::ZeroStateComponent < ViewComponent::Base
  renders_one :title
  renders_one :actions
end
