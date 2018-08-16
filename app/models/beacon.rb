# == Schema Information
#
# Table name: beacons
#
#  id          :bigint(8)        not null, primary key
#  mac_address :string(100)      not null
#  brand       :string(200)
#  model       :string(200)
#  chair_id    :bigint(8)        not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#


class Beacon < ActiveRecord::Base
  belongs_to :chair
  has_many :measurements, dependent: :destroy

  validates :chair, presence: true
  validates :mac_address, presence: true, length: { maximum: 100, too_long: "100 characters is the maximum allowed" }
  validates :brand, length: { maximum: 200, too_long: "200 characters is the maximum allowed" }
  validates :model, length: { maximum: 200, too_long: "200 characters is the maximum allowed" }
end
