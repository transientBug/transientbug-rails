require "sidekiq/web"

Rails.application.routes.draw do
  namespace :admin do
  end
  get 'invites/index'
  get 'invites/create'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "pages#main"
  get "/home", to: "pages#home"

  match "/login", to: "sessions#index", via: [:get]
  match "/login", to: "sessions#new", via: [:post]
  match "/auth/:provider/callback", to: "sessions#create", via: [:get, :post]
  match "/logout", to: "sessions#destroy", via: [:get, :delete]

  resources :invites, only: [:show, :update]

  resource :profile, only: [:show, :update] do
    post "password"
  end

  resources :images do
    collection do
      get "search"
      get "tags/autocomplete", action: :autocomplete, as: "tags_autocomplete"
      get "tag/:tag", action: :tag, as: "tag"
    end
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

  post "/telegram/:token", to: "telegram_webhooks#webhook"

  mount Sidekiq::Web => "/sidekiq" if Rails.env.development?
end
