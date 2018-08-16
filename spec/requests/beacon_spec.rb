require 'rails_helper'

RSpec.describe 'Beacon requests' do
  before(:all) do
    Rails.application.load_seed
  end
  after(:all) do
    Chair.destroy_all
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

  describe 'GET /beacons/:id/fetch_data' do
    it "fetches the last number of measurements' values for the beacon" do
      limit = 200
      params = {limit: limit}

      beacon = Beacon.with_mac_address("0a:bb:1p:00:56").first

      get("/beacons/#{beacon.id}/fetch_data", params: params)
      json = JSON.parse(response.body)

      expect(response).to have_http_status(:success)
      expect(json['measurements'].size).to be(limit)
    end
  end
end