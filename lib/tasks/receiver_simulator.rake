require 'csv'
task receiver_simulator: :environment do
  session = ActionDispatch::Integration::Session.new(Rails.application)
  measurements_controller = MeasurementsController.new


  times = 100
  # measurements_controller.create data
  # byebug
  # session.post("/measurements", data)
  # csv_text = File.read("#{Rails.root}/training/RSSIsensor1.csv")
  csv_text = File.read("#{Rails.root}/training/DataSet2sensor1.csv")
  csv = CSV.parse(csv_text, :headers => true)
  beacon1 = []
  cont1 = 0
  csv.each do |row|
    beacon1 << row["value"].to_f
    cont1 +=1
  end

  # csv_text = File.read("#{Rails.root}/training/RSSIsensor2.csv")
  csv_text = File.read("#{Rails.root}/training/DataSet2sensor2.csv")
  csv = CSV.parse(csv_text, :headers => true)
  beacon2 = []
  cont2 = 0
  csv.each do |row|
    beacon2 << row["value"].to_f
    cont2 += 1
  end

  # csv_text = File.read("#{Rails.root}/training/RSSIsensor3.csv")
  csv = CSV.parse(csv_text, :headers => true)
  beacon3 = []
  cont3 = 0
  csv.each do |row|
    beacon3 << row["value"].to_f
    cont3 += 1
  end

  if cont1 == cont2
    (0..times).each do |t|
      (0..cont1).each do |i|
        data = {measurements:[
          {"value": beacon1[i], "mac_address": "24:0a:c4:12:ca:ba"}, 
          {"value": beacon2[i], "mac_address": "30:ae:a4:0d:b9:56"}
          # {"value": beacon3[i], "mac_address": "24:0a:c4:13:5f:4a"}
        ]}
        session.post("/measurements", {params: data})
        puts "MEASUREMENTS SENT"
        sleep(0.2)
      end
    end
  else
    puts "FILES HAVE DIFFERENT NUMBER OF MEASUREMENTS"
  end


  # (1..250).each do |i|
  #   value1 = rand(-75..-45)
  #   value2 = rand(-75..-45)
  #   value3 = rand(-75..-45)
  #   data = {measurements:[
  #     {"value": value1, "mac_address": "24:0a:c4:12:ca:ba"}, 
  #     {"value": value2, "mac_address": "30:ae:a4:0d:b9:56"}, 
  #     {"value": value3, "mac_address": "a5:ae:a4:0d:b9:kk"},
  #   ]}
  #   session.post("/measurements", {params: data})
  #   sleep(0.2)
  # end

end