# frozen_string_literal: true

class Admin::PageHeaderComponent < ViewComponent::Base
  renders_one :title
  renders_one :tabs
  renders_one :actions
end
