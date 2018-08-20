# == Schema Information
#
# Table name: beacons
#
#  id          :bigint(8)        not null, primary key
#  mac_address :string(100)      not null
#  brand       :string(200)
#  model       :string(200)
#  chair_id    :bigint(8)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Beacon < ActiveRecord::Base

  MAX_SECONDS_TO_ACTIVE = 5

  belongs_to :chair, optional: true
  has_many :measurements, dependent: :destroy

  validates :mac_address, uniqueness: true, presence: true, length: { maximum: 100, too_long: "100 characters is the maximum allowed" }
  validates :brand, length: { maximum: 200, too_long: "200 characters is the maximum allowed" }
  validates :model, length: { maximum: 200, too_long: "200 characters is the maximum allowed" }

  scope :with_mac_address, -> (mac_address) { where(mac_address: mac_address) }

  def active?
    m = self.measurements.last
    seconds = MAX_SECONDS_TO_ACTIVE
    seconds = (Time.current - m.created_at).seconds if m.present?

    return (seconds < MAX_SECONDS_TO_ACTIVE)
  end

  def as_json(options={})
    chair_name = "No Chair"
    chair_name = self.chair.name if self.chair.present?
    
    return super().merge(chair_name: chair_name)
  end
end
