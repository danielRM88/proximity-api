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

  validates :chair, presence: true
  validates :filter_result, numericality: { less_than_or_equal_to: 1000000 }, allow_nil: true
  validates :algorithm_result, presence: true, numericality: { less_than_or_equal_to: 1000000 }
  validates :seated, inclusion: { in: [ true, false ] }, allow_nil: false
end
