class MeasurementsController < ApplicationController
  def create
    measurements = params[:measurements]
    measurements.each do |measurement|
      value = measurement[:value]
      mac_address = measurement[:mac_address]
      beacon = Beacon.with_mac_address(mac_address).first

      if beacon.present?
        chair = beacon.chair

        if chair.present?
          if chair.ongoing_calibration?
            CalibrationData.create!(chair: chair, beacon: beacon, value: value)
            Rails.logger.info "Calibration data with #{value} for beacon #{mac_address} stored..."
            chair.perform_calibration_checks
          elsif chair.calibrated?
            Measurement.create!(chair: chair, beacon: beacon, value: value)
            Rails.logger.info "Measurement #{value} for beacon #{mac_address} stored..."
          end
        end
      end
    end

    render :no_content, status: 200
  end
end