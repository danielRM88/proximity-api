# == Schema Information
#
# Table name: measurements
#
#  id            :bigint(8)        not null, primary key
#  value         :float            not null
#  chair_id      :bigint(8)        not null
#  beacon_id     :bigint(8)        not null
#  prediction_id :bigint(8)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Measurement < ActiveRecord::Base
  belongs_to :chair
  belongs_to :beacon
  belongs_to :prediction, optional: true

  validates :chair, presence: true
  validates :beacon, presence: true
  validates :value, presence: true, numericality: { less_than_or_equal_to: 100000 }
end
