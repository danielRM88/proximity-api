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

require 'rails_helper'

RSpec.describe Beacon do
  it { should belong_to(:chair) }
  it { should have_many(:measurements) }
  it { should validate_presence_of(:mac_address) }
  it { should validate_length_of(:mac_address).is_at_most(100).with_message("100 characters is the maximum allowed") }
  it { should validate_length_of(:brand).is_at_most(200).with_message("200 characters is the maximum allowed") }
  it { should validate_length_of(:model).is_at_most(200).with_message("200 characters is the maximum allowed") }
  it { should have_db_index(:mac_address).unique(true) }

  it "destroys dependent measurements when deleted" do
    chair = Chair.create(name: "My Chair")
    beacon = Beacon.create(mac_address: "beacon1", chair: chair)
    beacon_id = beacon.id
    measurement1 = Measurement.create(chair: chair, beacon: beacon, value: -58)
    measurement2 = Measurement.create(chair: chair, beacon: beacon, value: -68)

    measurements = Measurement.where(beacon_id: beacon_id)
    expect(measurements.count).to be(2)

    beacon.destroy
    measurements = Measurement.where(beacon_id: beacon_id)
    expect(measurements.count).to be(0)
  end

  describe '.with_mac_address' do
    it 'returns the beacon with the desired mac_address' do
      chair = Chair.create(name: "My Chair")
      beacon1 = Beacon.create(mac_address: "beacon1", chair: chair)
      beacon2 = Beacon.create(mac_address: "beacon2", chair: chair)

      result = Beacon.with_mac_address("beacon1")

      expect(result).to contain_exactly(beacon1)
    end
  end

  describe '#active' do
    context 'the beacon has a new measurement in the last 5 seconds' do
      subject { Beacon.create(chair: Chair.create(name: "chair"), mac_address: "mm:oo:u0:p1:44") }

      it 'returns true' do
        m = Measurement.create(beacon: subject, chair: subject.chair, value: -56)
        expect(subject.active?).to be(true)
      end
    end

    context 'the beacon has not had a new measurement in the last 5 seconds' do
      subject { Beacon.create(chair: Chair.create(name: "chair"), mac_address: "mm:oo:u0:p1:44") }

      it 'returns true' do
        m = Measurement.create(beacon: subject, chair: subject.chair, value: -56, created_at: (Time.current - 5.seconds))
        expect(subject.active?).to be(false)
      end
    end
  end
end
