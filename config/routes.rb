require "sidekiq/web"

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "pages#main"

  get "/home", to: "pages#home"
  resources :images do
    collection do
      get "search"
      get "tags/autocomplete", action: :autocomplete, as: "tags_autocomplete"
      get "tag/:tag", action: :tag, as: "tag"
    end
  end

  match "/auth/:provider/callback", to: "sessions#create", via: [:get, :post]
  match "/logout", to: "sessions#destroy", via: [:get, :delete]

  post "/telegram/:token", to: "telegram_webhooks#webhook"

  mount Sidekiq::Web => "/sidekiq"
end
