require_relative "../../lib/role_constraint"

namespace :admin, constraints: RoleConstraint.new(:admin) do
  root "home#home"

  resources :service_announcements do
    scope module: :service_announcements do
      resources :toggle, only: [ :create ]

      scope as: :service_announcements do
        collection do
          namespace :bulk do
            resource :deactivate, only: [:update]
            resource :delete, only: [:destroy]
          end
        end
      end
    end
  end

  resources :invitations do
    scope module: :invitations, as: :invitations do
      collection do
        namespace :bulk do
          resource :disable, only: [:destroy]
          resource :delete, only: [:destroy]
        end
      end
    end
  end

  resources :users, only: [ :index, :new, :create, :show, :edit, :update ] do
    scope module: :users do
      resources :password, only: [ :index, :create ]

      # scope as: :users do
      #   collection do
      #     namespace :bulk do
      #       resource :disable, only: [:destroy]
      #     end
      #   end
      # end
    end
  end

  resources :roles

  resources :bookmarks, only: [ :index, :show, :destroy ] do
    scope module: :bookmarks do
      resources :cache, only: [ :create ]

      scope as: :bookmarks do
        collection do
          namespace :bulk do
            resource :recache, only: [ :create ]
            resource :delete, only: [ :destroy ]
          end
        end
      end
    end
  end

  resources :applications, only: [ :index, :show, :edit, :update, :destroy ]
end
