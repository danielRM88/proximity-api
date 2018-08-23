# == Schema Information
#
# Table name: ground_truths
#
#  id       :bigint(8)        not null, primary key
#  chair_id :bigint(8)        not null
#  active   :boolean          default(FALSE), not null
#  seated   :boolean          default(FALSE), not null
#  gender   :string(255)
#  height   :float            default(0.0)
#  weight   :float            default(0.0)
#

class GroundTruth < ActiveRecord::Base
  belongs_to :chair

  validates :chair, presence: true
  validates :seated, inclusion: { in: [ true, false ] }, allow_nil: false
  validates :active, inclusion: { in: [ true, false ] }, allow_nil: false
  validates :gender, inclusion: { in: [ "male", "female" ] }, allow_nil: true
  validates :height, numericality: { less_than_or_equal_to: 1000000 }, allow_nil: true
  validates :weight, numericality: { less_than_or_equal_to: 1000000 }, allow_nil: true
end
