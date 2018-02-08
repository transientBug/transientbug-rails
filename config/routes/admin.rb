namespace :admin do
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
      resources :password, only: [ :create ]

      scope as: :users do
        collection do
          namespace :bulk do
            resource :disable, only: [:destroy]
          end
        end
      end
    end
  end

  resources :bookmarks do
    scope module: :bookmarks do
      resources :cache, only: [:create]

      scope as: :bookmarks do
        collection do
          namespace :bulk do
            resource :recache, only: [:create]
            resource :delete, only: [:destroy]
          end
        end
      end
    end
  end
end
