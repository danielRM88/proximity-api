# == Schema Information
#
# Table name: predictions
#
#  id               :bigint(8)        not null, primary key
#  filter_result    :float
#  filter_variance  :float
#  algorithm_result :float            not null
#  seated           :boolean          not null
#  chair_id         :bigint(8)        not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Prediction < ActiveRecord::Base
  belongs_to :chair
  has_many :measurements
  has_one :ground_truth_value, dependent: :destroy

  validates :chair, presence: true
  validates :filter_result, numericality: { less_than_or_equal_to: 1000000 }, allow_nil: true
  validates :filter_variance, numericality: { less_than_or_equal_to: 1000000 }, allow_nil: true
  validates :algorithm_result, presence: true, numericality: { less_than_or_equal_to: 1000000 }
  validates :seated, inclusion: { in: [ true, false ] }, allow_nil: false

  def self.perform_predictions
    chairs = Chair.joins(:calibration).joins(:beacons).joins(:algorithm).where(calibrations: {calibrated: true}).order(:id)

    chairs.each do |chair|
      chair.perform_predictions
    end
  end
end
