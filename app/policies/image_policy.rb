# frozen_string_literal: true

class ImagePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.all.order(:title) if user&.permission? "images.admin"

      scope.where(disabled: false).order(:title)
    end
  end

  def create?
    user&.permission? "images.create"
  end

  def show?
    return !record.disabled? if user.blank?

    user.permission? "images.show"
  end

  def update?
    user&.permission? "images.update"
  end

  def destroy?
    user&.permission? "images.destroy"
  end

  def permitted_attributes
    [ :title, :tags, :source, :disabled ]
  end
end
