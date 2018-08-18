# == Schema Information
#
# Table name: chairs
#
#  id         :bigint(8)        not null, primary key
#  name       :string(100)      not null
#  notes      :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Chair do
  it { should have_one(:filter) }
  it { should have_one(:calibration) }
  it { should have_many(:measurements) }
  it { should have_many(:beacons) }
  it { should have_many(:predictions) }
  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).is_at_most(100).with_message("100 characters is the maximum allowed") }
  it { should have_db_index(:name).unique(true) }

  it "destroys dependent calibration when deleted" do
    chair = Chair.create(name: "My Chair")
    calibrations = Calibration.where(chair_id: chair.id)

    expect(chair.calibration).to be_eql(calibrations.first)
    expect(calibrations.count).to be(1)

    chair_id = chair.id
    chair.destroy
    calibrations = Calibration.where(chair_id: chair_id)
    expect(calibrations.count).to be(0)
  end

  it "destroys dependent filter when deleted" do
    chair = Chair.create(name: "My Chair")
    filter = Filter.create(chair: chair)
    filters = Filter.where(chair_id: chair.id)

    expect(filters.count).to be(1)

    chair_id = chair.id
    chair.destroy
    filters = Filter.where(chair_id: chair_id)
    expect(filters.count).to be(0)
  end

  # it "destroys dependent beacons when deleted" do
  #   chair = Chair.create(name: "My Chair")
  #   chair_id = chair.id
  #   beacon1 = Beacon.create(mac_address: "beacon1", chair: chair)
  #   beacon2 = Beacon.create(mac_address: "beacon2", chair: chair)
  #   beacon3 = Beacon.create(mac_address: "beacon3", chair: chair)

  #   beacons = Beacon.where(chair_id: chair_id)
  #   expect(beacons.count).to be(3)

  #   chair.destroy
  #   beacons = Beacon.where(chair_id: chair_id)
  #   expect(beacons.count).to be(0)
  # end

  it "destroys dependent predictions when deleted" do
    chair = Chair.create(name: "My Chair")
    chair_id = chair.id
    prediction1 = Prediction.create(chair: chair, algorithm_result: 48, seated: false)
    prediction2 = Prediction.create(chair: chair, algorithm_result: 49, seated: true)

    predictions = Prediction.where(chair_id: chair_id)
    expect(predictions.count).to be(2)

    chair.destroy
    predictions = Prediction.where(chair_id: chair_id)
    expect(predictions.count).to be(0)
  end

  it "destroys dependent measurements when deleted" do
    chair = Chair.create(name: "My Chair")
    chair_id = chair.id
    beacon = Beacon.create(mac_address: "beacon1", chair: chair)
    measurement1 = Measurement.create(chair: chair, beacon: beacon, value: -58)
    measurement2 = Measurement.create(chair: chair, beacon: beacon, value: -68)

    measurements = Measurement.where(chair_id: chair_id)
    expect(measurements.count).to be(2)

    chair.destroy
    measurements = Measurement.where(chair_id: chair_id)
    expect(measurements.count).to be(0)
    beacon.destroy
  end

  it "triggers create_calibration on create" do
    chair = Chair.new(name: "My Test Chair")
    expect(chair).to receive(:create_calibration)
    chair.save
  end

  describe "#create_calibration" do
    context "chair is new" do
      subject { described_class.new(name: "My new chair") }
      
      it "creates a calibration object for this chair" do
        subject.save
        calibrations = Calibration.where(chair_id: subject.id)

        expect(subject.calibration).to be_eql(calibrations.first)
        expect(calibrations.count).to be(1)
      end
    end

    context "chair is already saved in database" do
      subject { described_class.new(name: "My new chair") }

      it "does not create a calibration object for this chair" do
        subject.save
        calibrations = Calibration.where(chair_id: subject.id)

        expect(subject.calibration).to be_eql(calibrations.first)
        expect(calibrations.count).to be(1)

        subject.name = "My New Chair Name"
        subject.save
        calibrations = Calibration.where(chair_id: subject.id)

        expect(subject.calibration).to be_eql(calibrations.first)
        expect(calibrations.count).to be(1)
      end
    end
  end


end
