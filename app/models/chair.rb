# == Schema Information
#
# Table name: chairs
#
#  id         :bigint(8)        not null, primary key
#  name       :string(100)      not null
#  notes      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Chair < ActiveRecord::Base
  attr_accessor :apply_filter

  has_one :filter, dependent: :destroy
  has_one :calibration, dependent: :destroy
  has_many :measurements, dependent: :destroy
  has_many :beacons
  has_many :predictions, dependent: :destroy

  validates :name, presence: true, uniqueness: true, length: { maximum: 100, too_long: "100 characters is the maximum allowed" }

  after_create :create_calibration
  before_destroy :remove_beacons_association

  after_save :check_filter

  def remove_beacons_association
    self.beacons.update_all(chair_id: nil)
  end

  def create_calibration
    calibration = Calibration.create(chair: self)
  end

  def check_filter
    if apply_filter != nil
      if apply_filter == true && self.filter.blank?
        filter = Filter.new
        filter.chair = self
        filter.save
      elsif self.filter.present? && apply_filter == false
        self.filter.destroy
      end
    end
  end

  def has_filter
    return self.filter.present?
  end

  def calibrated?
    return self.calibration.calibrated?
  end

  def ongoing_calibration?
    return self.calibration.ongoing?
  end

  def get_calibration_progress
    return self.calibration.progress
  end

  def start_calibration records_to_calibrate
    self.calibration.start records_to_calibrate
  end

  def stop_calibration
    self.calibration.stop
  end

  def as_json(options = {})
    super(include: [:beacons, :calibration, :filter]).merge({has_filter: has_filter, calibrated: calibrated?})
  end
end
