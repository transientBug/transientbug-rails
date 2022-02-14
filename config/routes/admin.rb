require_relative "../../lib/permission_constraint"

constraints PermissionConstraint.new("admin.system.workers") do
  mount GoodJob::Engine => 'good_job'
end

constraints PermissionConstraint.new("admin.system.logs") do
  mount Logster::Web => "/logs"
end

namespace :admin, constraints: PermissionConstraint.new("admin.access") do
  root "home#home"

  get "/workers", to: "home#good_job"
  get "/logs", to: "home#logster"

  resources :service_announcements do
    scope module: :service_announcements do
      scope as: :service_announcements do
        collection do
          namespace :bulk do
            # resource :deactivate, only: [:update]
            # resource :delete, only: [:destroy]
          end
        end
      end
    end
  end

  resources :invitations do
    scope module: :invitations, as: :invitations do
      collection do
        namespace :bulk do
          # resource :disable, only: [:destroy]
          # resource :delete, only: [:destroy]
        end
      end
    end
  end

  resources :users, only: [ :index, :new, :create, :show, :edit, :update ] do
    scope module: :users do
      resources :password, only: [ :index, :create ]
    end
  end

  resources :roles

  resources :bookmarks, only: [ :index, :show, :destroy ] do
    scope module: :bookmarks do
      resources :cache, only: [ :create ]

      scope as: :bookmarks do
        collection do
          namespace :bulk do
            # resource :recache, only: [ :create ]
            # resource :delete, only: [ :destroy ]
          end
        end
      end
    end
  end

  resources :applications, only: [ :index, :show, :edit, :update, :destroy ]
end
