require 'rails_helper'

RSpec.describe 'Beacon requests' do
  before(:all) do
    Rails.application.load_seed
  end
  after(:all) do
    Chair.destroy_all
    Beacon.destroy_all
  end

  describe 'POST /beacons' do
    it 'creates a beacon' do
      chair = Chair.create(name: "My new chair")
      mac_address = "1c:ko:ll:18:50"

      params = {
        beacon: {
          mac_address: mac_address,
          brand: 'my brand',
          model: 'my model',
          chair_id: chair.id
        }
      }

      post('/beacons', params: params)
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['beacon']["mac_address"]).to eq(params[:beacon][:mac_address])

      beacon_count = Beacon.with_mac_address(mac_address).size
      expect(beacon_count).to eq(1)
    end
  end

  describe 'GET /beacons/fetch_data' do
    it "fetches the last number of measurements' values for all the beacons" do
      limit = 200

      beacon1 = Beacon.with_mac_address("0a:bb:1p:00:56").first
      beacon2 = Beacon.with_mac_address("0c:ss:4o:kk:80").first

      params = { beacons_ids: [beacon1.id, beacon2.id], limit: limit }

      get("/beacons/fetch_data", params: params)
      json = JSON.parse(response.body)

      expect(response).to have_http_status(:success)
      expect(json["#{beacon1.id}"]['measurements'].size).to be(limit)
      expect(json["#{beacon1.id}"]['mac_address']).to eq(beacon1.mac_address)
      expect(json["#{beacon2.id}"]['measurements'].size).to be(limit)
      expect(json["#{beacon2.id}"]['mac_address']).to eq(beacon2.mac_address)
    end

    it "returns an empty array if there are no measurements to return" do
      Measurement.destroy_all
      limit = 0

      beacon1 = Beacon.with_mac_address("0a:bb:1p:00:56").first
      beacon2 = Beacon.with_mac_address("0c:ss:4o:kk:80").first

      params = { beacons_ids: [beacon1.id, beacon2.id], limit: limit }

      get("/beacons/fetch_data", params: params)
      json = JSON.parse(response.body)

      expect(response).to have_http_status(:success)
      expect(json["#{beacon1.id}"]['measurements'].size).to be(limit)
      expect(json["#{beacon2.id}"]['measurements'].size).to be(limit)
    end
  end
end