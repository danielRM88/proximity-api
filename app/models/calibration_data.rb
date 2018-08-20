class CalibrationData < ActiveRecord::Base
  belongs_to :chair
  belongs_to :beacon

  validates :chair, presence: true
  validates :beacon, presence: true
  validates :value, presence: true, numericality: { less_than_or_equal_to: 100000 }
end