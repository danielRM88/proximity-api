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

require 'rails_helper'

RSpec.describe Prediction do
  it { should belong_to(:chair) }
  it { should validate_presence_of(:chair) }
  it { should have_many(:measurements) }
  it { should validate_numericality_of(:filter_result).is_less_than_or_equal_to(1000000) }
  it { should validate_presence_of(:algorithm_result) }
  it { should validate_numericality_of(:algorithm_result).is_less_than_or_equal_to(1000000) }
end
