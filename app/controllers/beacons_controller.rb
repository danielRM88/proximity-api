class BeaconsController < ApplicationController
  before_action :set_beacon, except: [:create]

  def create
    beacon = Beacon.create!(beacon_params)

    render json: {beacon: beacon, status: 200}
  end

  def fetch_data
    limit = params[:limit]
    measurements = Measurement.where(beacon_id: @beacon.id).order(:id).limit(limit)

    render json: {measurements: measurements.pluck(:value), status: 200}
  end

private 
  def set_beacon
    @beacon = Beacon.find(params[:id])
  end

  def beacon_params
    params.require(:beacon).permit(:mac_address, :brand, :model, :chair_id)
  end
end