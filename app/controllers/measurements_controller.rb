class MeasurementsController < ApplicationController
  def create
    measurements = params[:measurements]
    measurements.each do |measurement|
      value = measurement[:value]
      mac_address = measurement[:mac_address]
      beacon = Beacon.with_mac_address(mac_address).first

      if beacon.present?
        chair = beacon.chair
        Measurement.create!(chair: chair, beacon: beacon, value: value)
      end
    end

    render :no_content, status: 200
  end
end