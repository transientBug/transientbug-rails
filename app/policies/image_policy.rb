class ImagePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.all.order(:title) if user.present?
      scope.where(disabled: false).order(:title)
    end
  end

  def create?
    return false unless user.present?

    true
  end

  def show?
    return !record.disabled? unless user.present?

    return true if user.role? :admin

    user.owner_of? record
  end

  def permitted_attributes
    [ :title, :tags, :source, :disabled ]
  end
end
