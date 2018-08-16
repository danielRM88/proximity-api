# == Schema Information
#
# Table name: calibrations
#
#  id                   :bigint(8)        not null, primary key
#  chair_id             :bigint(8)        not null
#  calibrated           :boolean          default(FALSE), not null
#  records_to_calibrate :integer          default(100), not null
#

class Calibration < ActiveRecord::Base
  belongs_to :chair

  validates :chair, presence: true
  validates :records_to_calibrate, presence: true, numericality: { less_than_or_equal_to: 100000,  only_integer: true }
end
