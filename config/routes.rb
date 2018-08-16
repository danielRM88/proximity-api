Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # post 'measurement' => 'measurements#create'
  resources :measurements, only: [:create]
  resources :beacons do
    member do
      get 'fetch_data'
    end
  end
end
