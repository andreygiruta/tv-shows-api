Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  # API routes
  namespace :api do
    namespace :v1 do
      resources :tvshows, only: [:index], controller: 'tv_shows'

      # Show-specific endpoints
      get 'shows', to: 'tv_shows#shows'
      get 'shows/:id/episodes', to: 'tv_shows#show_episodes'

      # Filter data endpoints
      get 'networks', to: 'tv_shows#networks'
      get 'countries', to: 'tv_shows#countries'
    end
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
