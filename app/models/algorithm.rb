# == Schema Information
#
# Table name: algorithms
#
#  id               :bigint(8)        not null, primary key
#  chair_id         :bigint(8)        not null
#  algorithm_name   :string           not null
#  serialized_class :json             not null
#

class Algorithm < ActiveRecord::Base
  belongs_to :chair
  serialize :serialized_class

  validates :chair, presence: true
  validates :algorithm_name, presence: true
  validates :serialized_class, presence: true

  def perform x
    algorithm = YAML::load(self.serialized_class)
    result = algorithm.perform x
    self.serialized_class = YAML::dump(algorithm)
    self.save

    return result
  end
end
