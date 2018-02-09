namespace :api do
  namespace :v1 do
    # Disable having to .json the request url but default to JSON. Don't
    # include the new and edit routes that normal html routes expect
    scope format: false, except: [ :new, :edit ], defaults: { format: :jsonapi } do
      resource :profile, only: [ :show ]
      resources :bookmarks do
        collection do
          resources :check, only: [ :index ], module: "bookmarks"
        end
      end
    end
  end
end
