class BeaconsController < ApplicationController
  before_action :set_beacon, except: [:create, :fetch_data]

  def create
    beacon = Beacon.create!(beacon_params)

    render json: {beacon: beacon, status: 200}
  end

  def fetch_data
    limit = params[:limit]
    response = {}

    beacons_ids = params[:beacons_ids]

    if beacons_ids.class == String
      beacons_ids = JSON.parse(beacons_ids)
    end

    beacons_ids.each do |id|
      b = Beacon.find(id)
      measurements = b.measurements.order(:id).last(limit)
      response[b.id] = {mac_address: b.mac_address, active: b.active?, measurements: measurements.pluck(:value)}
    end

    render json: response, status: 200
  end

private 
  def set_beacon
    @beacon = Beacon.find(params[:id])
  end

  def beacon_params
    params.require(:beacon).permit(:mac_address, :brand, :model, :chair_id)
  end
end