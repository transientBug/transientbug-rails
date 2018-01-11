class BookmarkPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      # return scope.all if user.present?
      scope.order(:created_at)
    end
  end

  def create?
    return false unless user.present?
    true
  end

  def show?
    return scope.where(id: record.id).exists? if user.present?

    scope.where(id: record.id).exists?
  end

  def update?
    return false unless user.present?
    user.owner_of? record
  end

  def edit?
    return false unless user.present?
    user.owner_of? record
  end

  def destroy?
    return false unless user.present?
    user.owner_of? record
  end

  def permitted_attributes
    [ :title, :description ]
  end
end