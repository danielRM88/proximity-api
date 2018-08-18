# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
Chair.destroy_all
chair = Chair.create(name: "My Seed Chair")
beacon1 = Beacon.create(chair: chair, mac_address: "0a:bb:1p:00:56")
beacon2 = Beacon.create(chair: chair, mac_address: "0c:ss:4o:kk:80")

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
end