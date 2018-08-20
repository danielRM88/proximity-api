# == Schema Information
#
# Table name: calibrations
#
#  id                   :bigint(8)        not null, primary key
#  chair_id             :bigint(8)        not null
#  calibrated           :boolean          default(FALSE), not null
#  ongoing              :boolean          default(FALSE), not null
#  records_to_calibrate :integer          default(100), not null
#

class Calibration < ActiveRecord::Base
  belongs_to :chair

  validates :chair, presence: true
  validates :records_to_calibrate, presence: true, numericality: { less_than_or_equal_to: 100000, greater_than: 0,  only_integer: true }

  def progress
    beacons = self.chair.beacons.count
    calibrationData = CalibrationData.where(chair_id: chair.id).count
    denominator = (beacons*self.records_to_calibrate)

    progress = 0
    progress = (calibrationData*100 / denominator) if denominator > 0

    return progress
  end

  def start records_to_calibrate = nil
    self.ongoing = true
    self.calibrated = false
    self.records_to_calibrate = records_to_calibrate if records_to_calibrate.present?

    self.save
  end

  def finished?
    return (progress == 100)
  end

  def stop
    self.ongoing = false
    self.calibrated = finished?

    self.save
  end

  def as_json(options = {})
    super().merge({progress: self.progress})
  end
end
