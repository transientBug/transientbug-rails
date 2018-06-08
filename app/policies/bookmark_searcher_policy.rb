class BookmarkSearcherPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.new.scope({ term: { user_id: user.id } })
    end
  end
end
