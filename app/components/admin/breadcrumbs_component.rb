# frozen_string_literal: true

class Admin::BreadcrumbsComponent < ViewComponent::Base
  renders_many :crumbs, "CrumbComponent"

  class CrumbComponent < ViewComponent::Base
    attr_reader :name, :href

    def initialize(name:, href:)
      super

      @name = name
      @href = href
    end
  end
end
