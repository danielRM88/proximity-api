Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # post 'measurement' => 'measurements#create'
  resources :chairs do 
    member do
      get '/predictions' => 'chairs#get_predictions'
    end
  end
  resources :beacons, only: [:create]
  get 'beacons/fetch_data' => 'beacons#fetch_data'
  resources :measurements, only: [:create]
end
