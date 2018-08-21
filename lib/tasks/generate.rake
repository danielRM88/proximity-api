namespace :generate do
  desc 'Generate measurements and predictions for simulation'
  task data: :environment do
    # Chair.destroy_all
    chair = Chair.where(name: "My Seed Chair").first
    if chair.blank?
      chair = Chair.create(name: "My Seed Chair")
    end

    beacon1 = Beacon.where(mac_address: "30:ae:a4:0d:b9:56").first
    if beacon1.blank?
      beacon1 = Beacon.create(chair: chair, mac_address: "30:ae:a4:0d:b9:56") 
    else
      beacon1.update(chair: chair)
    end
    
    beacon2 = Beacon.where(mac_address: "24:0a:c4:12:ca:ba").first
    if beacon2.blank?
      beacon2 = Beacon.create(chair: chair, mac_address: "24:0a:c4:12:ca:ba") 
    else
      beacon2.update(chair: chair)
    end

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