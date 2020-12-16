require "sidekiq/web"
require_relative "../lib/permission_constraint"

def draw name
  path = Rails.root.join "config", "routes", "#{ name }.rb"
  instance_eval path.read, path.to_s
end

Rails.application.routes.draw do
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
  get "/faq", to: "pages#faq"

  get "/privacy", to: "pages#privacy"
  get "/tos", to: "pages#tos"

  match "/login", to: "sessions#index", via: [:get]
  match "/login", to: "sessions#new", via: [:post]
  match "/auth/:provider/callback", to: "sessions#create", via: [:get, :post]
  match "/logout", to: "sessions#destroy", via: [:get, :delete]

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
        resource :delete, only: [:destroy]
      end
    end

    namespace :authorized_applications do
      namespace :bulk do
        resource :revoke, only: [:destroy]
      end
    end
  end

  resources :tags, only: [:index, :show]

  resources :bookmarks do
    scope module: :bookmarks do
      resources :cache, only: [:index, :create] do
        collection do
          match "/*key", to: "cache#show", via: [:get]
        end
      end
    end
  end

  draw :admin
  draw :api

  # Error pages
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  resources :csp_violation_report, only: [:create], path: '/csp-violation-report', format: false, defaults: { format: :js }

  constraints PermissionConstraint.new("admin.sidekiq") do
    mount Sidekiq::Web => "/sidekiq"
  end

  if Rails.env.production?
    constraints PermissionConstraint.new("admin.logs") do
      mount Logster::Web => "/logs"
    end
  end
end
