Rails.application.routes.draw do
  get "rankings/show"
  get "ranking/show"
  resources :reports, only: [] do
    collection do
      get :daily
      get :weekly
      get :monthly
      get :yearly
      get :all
    end
  end
  devise_for :users
  root 'tasks#index'
  resources :tasks do
    member do
      patch :start
      patch :give_up
      patch :finish
    end
    collection do
      get :future  
    end
  end

  


  resources :users, only: %i[show]
  resources :rankings, only: %i[show]
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
