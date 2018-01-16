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
    get "/cache", to: "webpage_cache#index"
    match "/cache/assets/*key", to: "webpage_cache#assets", via: [:get]

    collection do
      get "search"
      get "tags/autocomplete", action: :autocomplete, as: "tags_autocomplete"
      get "tag/:tag", action: :tag, as: "tag"
    end
  end

  namespace :admin do
    root "home#home"

    resources :service_announcements

    resources :invitations
    resources :users, only: [ :index, :show, :edit, :update ] do
      # Trying out the pattern talked about here
      # http://jeromedalbert.com/how-dhh-organizes-his-rails-controllers/
      resources :password, only: [ :create ], module: "users"
    end

    resources :bookmarks
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
