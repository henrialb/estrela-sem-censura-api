Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', :as => :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # API routes
  namespace :api do
    post '/auth/facebook', to: 'auth#facebook'
    get '/auth/me', to: 'users#me'
    post '/callbacks/facebook/delete', to: 'callbacks#facebook_delete'

    resources :posts, only: %i[index create] do
      resources :comments, only: :create
    end
  end
end
