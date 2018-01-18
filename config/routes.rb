require "sidekiq/web"

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "pages#main"
  get "/home", to: "pages#home"
  get "/faq", to: "pages#faq"

  match "/login", to: "sessions#index", via: [:get]
  match "/login", to: "sessions#new", via: [:post]
  match "/auth/:provider/callback", to: "sessions#create", via: [:get, :post]
  match "/logout", to: "sessions#destroy", via: [:get, :delete]

  resources :invites, only: [:index, :create, :show, :update]

  resource :profile, only: [:show, :update] do
    post "password"
  end

  resources :bookmarks do
    resources :cache, only: [:index, :create], module: "bookmarks" do
      collection do
        match "/*key", to: "cache#show", via: [:get]
      end
    end

    collection do
      scope as: :bookmarks, module: :bookmarks do
        resources :search, only: [:index]
        resources :tags, only: [:index, :show] do
          collection do
            resources :autocomplete, only: [:index], module: "tags"
          end
        end
      end
    end
  end

  namespace :admin do
    root "home#home"

    resources :service_announcements

    resources :invitations
    resources :users, only: [ :index, :show, :edit, :update ] do
      resources :password, only: [ :create ], module: "users"
    end

    resources :bookmarks
  end

  namespace :api do
    namespace :v1 do
      # Disable having to .json the request url but default to JSON. Don't
      # include the new and edit routes that normal html routes expect
      scope format: false, except: [ :new, :edit ], defaults: { format: :json } do
        resource :profile, only: [ :show ]
      end
    end
  end

  resources :images do
    collection do
      get "search"
      get "tags/autocomplete", action: :autocomplete, as: "tags_autocomplete"
      get "tag/:tag", action: :tag, as: "tag"
    end
  end

  post "/telegram/:token", to: "telegram_webhooks#webhook"

  # This should be locked down actually rather than disabled outside of dev
  mount Sidekiq::Web => "/sidekiq" if Rails.env.development?
end
