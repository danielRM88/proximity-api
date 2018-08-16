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

require 'rails_helper'

RSpec.describe Measurement do
  it { should belong_to(:chair) }
  it { should validate_presence_of(:chair) }
  it { should belong_to(:beacon) }
  it { should validate_presence_of(:beacon) }
  it { should belong_to(:prediction) }
  it { should validate_numericality_of(:value).is_less_than_or_equal_to(100000) }
end
