require 'rails_helper'

RSpec.describe 'Chair requests' do
  before(:all) do
    Rails.application.load_seed
  end
  after(:all) do
    Chair.destroy_all
    Beacon.destroy_all
  end

  describe 'GET /chairs' do
    it 'should return an array of all chairs in the system' do
      get('/chairs')
      json = JSON.parse(response.body)

      expect(json.size).to eq(Chair.count)
    end
  end

  describe 'GET /chairs/:id' do
    it 'returns the details of the specified chair' do
      chair = Chair.last

      get("/chairs/#{chair.id}")
      json = JSON.parse(response.body)

      expect(response).to have_http_status(:success)
      expect(json['name']).to eq(chair.name)
    end
  end

  describe 'POST /chairs' do
    it 'creates a chair' do
      chairs_name = "my chair name"
      params = {
        chair: {
          name: chairs_name,
          notes: 'my notes',
        }
      }

      post('/chairs', params: params)
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['chair']["name"]).to eq(params[:chair][:name])

      chairs_count = Chair.where(name: chairs_name).size
      expect(chairs_count).to eq(1)
    end
  end

  describe 'GET /predictions' do
    it "fetches the last number of predictions for the chair" do
      limit = 150

      chair = Chair.where(name: "My Seed Chair").first

      params = { chair_id: chair.id, limit: limit }

      get("/chairs/#{chair.id}/predictions", params: params)
      json = JSON.parse(response.body)

      expect(response).to have_http_status(:success)
      expect(json['predictions'].size).to be(limit)
    end
  end
end