require 'rails_helper'

RSpec.describe 'Measurement requests' do
  describe 'POST /measurements' do
    it 'registers the measurements' do
      mac_address_beacon1 = "ac:59:ks:0a:99"
      mac_address_beacon2 = "bc:10:jj:0a:gg"

      chair = Chair.create(name: "My Chair")
      beacon1 = Beacon.create(chair: chair, mac_address: mac_address_beacon1)
      beacon2 = Beacon.create(chair: chair, mac_address: mac_address_beacon2)

      params = {
        measurements: [
          {value: -58, mac_address: mac_address_beacon1}, 
          {value: -90, mac_address: mac_address_beacon2}
        ]
      }

      measurements_count = Measurement.count
      post('/measurements', params: params)
      expect(response).to have_http_status(:success)

      measurement1 = Measurement.where(value: -58, beacon_id: beacon1.id)
      expect(measurement1).to_not be(nil)

      measurement2 = Measurement.where(value: -58, beacon_id: beacon2.id)
      expect(measurement2).to_not be(nil)

      expect(Measurement.count).to be(measurements_count+2)
    end
  end
end