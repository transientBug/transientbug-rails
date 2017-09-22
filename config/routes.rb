require 'sidekiq/web'

Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root "pages#main"

  get "/home", to: "pages#home"
  resources :bookmarks

  match "/auth/:provider/callback", to: "sessions#create", via: [:get, :post]
  match "/logout", to: "sessions#destroy", via: [:get, :delete]

  mount Sidekiq::Web => '/sidekiq'
end
