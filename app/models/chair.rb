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
  has_one :filter, dependent: :destroy
  has_one :calibration, dependent: :destroy
  has_many :measurements, dependent: :destroy
  has_many :beacons, dependent: :destroy
  has_many :predictions, dependent: :destroy

  validates :name, presence: true, length: { maximum: 100, too_long: "100 characters is the maximum allowed" }

  after_create :create_calibration

  def create_calibration
    calibration = Calibration.create(chair: self)
  end

  def has_filter
    return self.filter.present?
  end

  def as_json(options = {})
    super(include: :beacons).merge({has_filter: has_filter})
  end
end
