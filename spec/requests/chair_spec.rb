require 'rails_helper'

RSpec.describe 'Chair requests' do
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
end