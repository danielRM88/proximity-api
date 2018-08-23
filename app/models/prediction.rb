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
  MAX_TIME_BETWEEN_MEASUREMENTS = 0.5

  belongs_to :chair
  has_many :measurements
  has_one :ground_truth_value, dependent: :destroy

  validates :chair, presence: true
  validates :filter_result, numericality: { less_than_or_equal_to: 1000000 }, allow_nil: true
  validates :filter_variance, numericality: { less_than_or_equal_to: 1000000 }, allow_nil: true
  validates :algorithm_result, presence: true, numericality: { less_than_or_equal_to: 1000000 }
  validates :seated, inclusion: { in: [ true, false ] }, allow_nil: false

  def self.perform_predictions
    chairs = Chair.joins(:calibration).joins(:beacons).joins(:algorithm).where(calibrations: {calibrated: true}).order(:id)

    chairs.each do |chair|
      beacons = chair.beacons.order(:id)
      measurements = []

      beacons.each do |beacon|
        last_predicted = beacon.measurements.where.not(prediction_id: nil).last
        m = beacon.measurements.where(prediction_id: nil)

        if last_predicted.present?
          m = m.where("id > #{last_predicted.id}")
        end

        m = m.last
        measurements << m if m.present?
      end

      if measurements.size == beacons.size && measurements.size > 0
        Rails.logger.info "LOOKING FOR MEASUREMENTS"
        time_diff = 0
        measurements.each do |m1|
          measurements.each do |m2|
            if m1.id != m2.id
              diff = ((m1.created_at - m2.created_at).seconds).abs
              if diff > time_diff
                time_diff = diff
              end
            end
          end
        end

        if time_diff <= MAX_TIME_BETWEEN_MEASUREMENTS
          pred = Prediction.new(chair_id: chair.id)
          output = nil
          variance = nil
          filter = chair.filter
          algrithm_input = nil
          if filter.present?
            y = Matrix.build(measurements.size, 1){ 0 }
            measurements.each_with_index do |m, index|
              y[index, 0] = m.value
            end
            Rails.logger.info "TRAINING FILTER #{y}"
            output = filter.filter y
            variance = filter.P
            pred.filter_result = output[0,0].round(5)
            pred.filter_variance = variance[0,0].round(5)
            algorithm_input = output[0,0]
          else
            algorithm_input = (measurements.inject(0) { |r, m| return r + m.value })/measurements.size
          end

          # call algorithm
          algorithm = chair.algorithm
          seated = algorithm.perform algorithm_input
          
          pred.algorithm_result = algorithm_input
          pred.seated = seated

          result = pred.save
          if result
            measurements.each do |me|
              me.update(prediction_id: pred.id)
            end
            ground_truth = chair.ground_truth
            if ground_truth.present? && ground_truth.active?
              gtv = GroundTruthValue.new(prediction: pred)
              gtv.seated = ground_truth.seated
              gtv.gender = ground_truth.gender
              gtv.height = ground_truth.height
              gtv.weight = ground_truth.weight
              gtv.save
            end
          end
        else
          Rails.logger.info "TIME DIFFERENCE TOO GREAT"
        end
      else 
        Rails.logger.info "NO MEASUREMENTS FOUND"
      end
    end

  end
end
