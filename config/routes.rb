Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  # post 'measurement' => 'measurements#create'
  resources :chairs do 
    member do
      get '/kmeans_data' => 'chairs#get_kmeans_data'
      get '/predictions' => 'chairs#get_predictions'
      get '/fetch_calibration_progress' => 'chairs#fetch_calibration_progress'
      post '/start_calibration' => 'chairs#start_calibration'
      put '/update_filter_process_noise' => 'chairs#update_filter_process_noise'
      put '/ground_truth' => 'chairs#update_ground_truth'
    end
  end
  get 'beacons/fetch_data' => 'beacons#fetch_data'
  resources :beacons
  resources :measurements, only: [:create]
end
