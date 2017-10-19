class ImagePolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
      # scope.where(user: user)
    end
  end

  # def show?
  #   user.owner_of? record
  # end

  def update?
    return false unless user
    user.owner_of? record
  end

  def new?
    return false unless user
    user.owner_of? record
  end

  def edit?
    return false unless user
    user.owner_of? record
  end

  def destroy?
    return false unless user
    user.owner_of? record
  end

  def permitted_attributes
    [:title, :tags, :source]
  end
end
