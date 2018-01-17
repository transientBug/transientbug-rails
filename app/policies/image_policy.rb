class ImagePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      return scope.all.order(:title) if user&.role? :admin
      scope.where(disabled: false).order(:title)
    end
  end

  def create?
    user&.role? :admin
  end

  def destroy?
    user&.role? :admin
  end

  def show?
    return !record.disabled? unless user.present?

    user.role? :admin
  end

  def permitted_attributes
    [ :title, :tags, :source, :disabled ]
  end
end
