# == Schema Information
#
# Table name: calibrations
#
#  id                   :bigint(8)        not null, primary key
#  chair_id             :bigint(8)        not null
#  calibrated           :boolean          default(FALSE), not null
#  ongoing              :boolean          default(FALSE), not null
#  records_to_calibrate :integer          default(100), not null
#

require 'rails_helper'

RSpec.describe Calibration do
  it { should belong_to(:chair) }
  it { should validate_numericality_of(:records_to_calibrate).only_integer.is_less_than_or_equal_to(100000) }
  it { should validate_presence_of(:records_to_calibrate) }
  it { should have_db_index(:chair_id).unique(true) }
end
