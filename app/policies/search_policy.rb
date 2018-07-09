class SearchPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.where(user: user).order(created_at: :desc)
    end
  end

  def show?
    user&.owner_of? record
  end

  def update?
    user&.owner_of? record
  end

  def destroy?
    user&.owner_of? record
  end

  def permitted_attributes
    [ :name, :description, :query ]
  end
end
