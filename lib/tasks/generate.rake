namespace :generate do
  desc 'Generate measurements and predictions for simulation'
  task data: :environment do
    chair = Chair.last

    if chair.blank?
      Rails.application.load_seed
      chair = Chair.last
    end

    beacon1 = Beacon.first
    beacon2 = Beacon.last

    n=200
    variance = 10

    (1..n).each do |n|
      value = rand(-75..-45)
      m1 = Measurement.create(chair: chair, beacon: beacon1, value: value)
      value = rand(-75..-45)
      m2 = Measurement.create(chair: chair, beacon: beacon2, value: value)

      value = rand(-60..-52)
      alg_value = rand(0..1)
      seated = false
      if alg_value > 0.5
        seated = true
      end  
      variance -= 0.01
      p = Prediction.create(filter_result: value, filter_variance: variance, algorithm_result: alg_value, seated: seated, chair: chair)

      sleep(0.5)
    end
  end
end