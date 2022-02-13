Rails.application.routes.draw do
  # Error pages
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  resources :csp_violation_report,
    only: [:create],
    path: '/csp-violation-report',
    format: false,
    defaults: { format: :js }

  use_doorkeeper do
    controllers(
      applications: "oauth/applications",
      authorized_applications: "oauth/authorized_applications",
      authorizations: "oauth/authorizations"
    )
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "pages#main"
  get "/home", to: "dashboard#index"

  match "/login", to: "sessions#index", via: [:get]
  match "/login", to: "sessions#new", via: [:post]
  match "/logout", to: "sessions#destroy", via: [:delete]

  resources :invites, only: [:index, :create, :show, :update]

  resource :profile, only: [:show, :update] do
    post "password"

    scope module: :profiles do
      resources :import, only: [ :index, :create ]
      resources :regenerate, only: [ :create ]
    end
  end

  namespace :oauth do
    namespace :applications do
      namespace :bulk do
        # resource :delete, only: [:destroy]
      end
    end

    namespace :authorized_applications do
      namespace :bulk do
        # resource :revoke, only: [:destroy]
      end
    end
  end

  resources :tags, only: [:index, :show]

  resources :bookmarks do
    scope module: :bookmarks do
      collection do
        scope as: :bookmarks do
          resources :search, only: [:index]
        end
      end

      resources :cache, only: [:index, :create] do
        collection do
          match "/*key", to: "cache#show", via: [:get]
        end
      end
    end
  end

  draw :api
  draw :admin

  get "/faq", to: "pages#faq"
  get "/privacy", to: "pages#privacy"
  get "/tos", to: "pages#tos"
  # get "/*", to: "pages#generic"
end
