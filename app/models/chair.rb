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

class Chair < ActiveRecord::Base
  MAX_TIME_BETWEEN_MEASUREMENTS = 0.5

  attr_accessor :apply_filter

  has_one :ground_truth, dependent: :destroy
  has_one :filter, dependent: :destroy
  has_one :algorithm, dependent: :destroy
  has_one :calibration, dependent: :destroy
  has_many :measurements, dependent: :destroy
  has_many :beacons
  has_many :predictions, dependent: :destroy

  validates :name, presence: true, uniqueness: true, length: { maximum: 100, too_long: "100 characters is the maximum allowed" }

  after_create :create_calibration_and_ground_truth
  before_destroy :remove_beacons_association

  after_save :check_filter

  def perform_predictions
    beacons = self.beacons.order(:id)
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
        Rails.logger.info "MEASUREMENTS FOUND"
        pred = Prediction.new(chair_id: self.id)
        output = nil
        variance = nil
        filter = self.filter
        algrithm_input = nil
        if filter.present?
          y = Matrix.build(measurements.size, 1){ 0 }
          measurements.each_with_index do |m, index|
            y[index, 0] = m.value
          end
          # Rails.logger.info "TRAINING FILTER #{y}"
          output = filter.filter y
          variance = filter.P
          pred.filter_result = output[0,0].round(5)
          pred.filter_variance = variance[0,0].round(5)
          algorithm_input = output[0,0]
        else
          algorithm_input = (measurements.inject(0) { |r, m| r + m.value })/measurements.size
        end

        # call algorithm
        algorithm = self.algorithm
        seated = algorithm.perform algorithm_input
        
        pred.algorithm_result = algorithm_input
        pred.seated = seated

        result = pred.save
        if result
          measurements.each do |me|
            me.update(prediction_id: pred.id)
          end
          ground_truth = self.ground_truth
          if ground_truth.present? && ground_truth.active?
            gtv = GroundTruthValue.new(prediction: pred)
            gtv.seated = ground_truth.seated
            gtv.gender = ground_truth.gender
            gtv.height = ground_truth.height
            gtv.weight = ground_truth.weight
            gtv.save
          end
        else
          Rails.logger.info pred.errors
        end
      else
        # Rails.logger.info "TIME DIFFERENCE TOO GREAT"
      end
    else 
      # Rails.logger.info "NO MEASUREMENTS FOUND"
    end
  end

  def performance
    tn = nil
    fp = nil
    tp = nil
    fn = nil
    accuracy = "0%"
    precision = "0%"
    recall = "0%"
    specificity = "0%"

    ps_with_gtv = self.predictions.joins(:ground_truth_value)
    if ps_with_gtv.count > 0
      tn = ps_with_gtv.where(seated: false).where(ground_truth_values: {seated: false}).count
      fp = ps_with_gtv.where(seated: true).where(ground_truth_values: {seated: false}).count
      tp = ps_with_gtv.where(seated: true).where(ground_truth_values: {seated: true}).count
      fn = ps_with_gtv.where(seated: false).where(ground_truth_values: {seated: true}).count

      denominator = tn+fp+tp+fn
      if denominator > 0
        accuracy = ""+(((tn+tp).to_f/denominator.to_f).round(2)*100).to_i.to_s+"%"
      end

      denominator = fp+tp
      if denominator > 0
        precision = ""+(((tp).to_f/denominator.to_f).round(2)*100).to_i.to_s+"%"
      end

      denominator = fn+tp
      if denominator > 0
        recall = ""+(((tp).to_f/denominator.to_f).round(2)*100).to_i.to_s+"%"
      end

      denominator = tn+fp
      if denominator > 0
        specificity = ""+(((tn).to_f/denominator.to_f).round(2)*100).to_i.to_s+"%"
      end
    end

    performance = {
      tn: tn,
      fp: fp,
      tp: tp,
      fn: fn,
      accuracy: accuracy,
      precision: precision,
      recall: recall,
      specificity: specificity
    }

    return performance
  end

  def remove_beacons_association
    self.beacons.update_all(chair_id: nil)
  end

  def create_calibration_and_ground_truth
    calibration = Calibration.create(chair: self)
    ground_truth = GroundTruth.create(chair: self)
  end

  def check_filter
    if apply_filter != nil
      if apply_filter == true && self.filter.blank?
        filter = Filter.new
        filter.chair = self
        filter.save
        self.calibration.update(calibrated: false)
      elsif self.filter.present? && apply_filter == false
        self.filter.destroy
        self.calibration.update(calibrated: false)
      end
    end
  end

  def reset_calibration
    self.filter.destroy if self.filter.present?
    self.calibration.update(calibrated: false)
  end

  def has_filter
    return self.filter.present?
  end

  def calibrated?
    return self.calibration.calibrated?
  end

  def ongoing_calibration?
    return self.calibration.ongoing?
  end

  def get_calibration_progress
    return self.calibration.progress
  end

  def start_calibration records_to_calibrate
    self.reset_calibration
    self.measurements.delete_all
    GroundTruthValue.joins(prediction: :chair).where(predictions: {chair_id: self.id}).delete_all
    self.predictions.delete_all
    self.ground_truth.update(active: false)
    CalibrationData.where(chair_id: self.id).delete_all

    filter = self.filter
    algorithm = self.algorithm
    if filter.present?
      filter.destroy
      filter = Filter.new
      filter.chair = self
      filter.save
    end
    
    algorithm.destroy if algorithm.present?
    algorithm = Algorithm.new
    kmeans = KMeans.new
    algorithm.chair = self
    algorithm.algorithm_name = kmeans.algorithm_name
    algorithm.serialized_class = YAML::dump(kmeans)
    algorithm.save

    self.calibration.start records_to_calibrate
  end

  def stop_calibration
    self.calibration.stop
  end

  def perform_calculations
    # set filter variables if there is any
    # Mostly we calculate the covariance matrix for the beacons (V2)
    variances = []
    v2 = Matrix.zero(self.beacons.count)
    data = []
    h = []

    mean_sum = 0
    variance_sum = 0
    sigma = 0
    no_records = self.calibration.records_to_calibrate

    beacons = self.beacons
    beacons.each_with_index do |beacon, index|
      data << CalibrationData.where(beacon_id: beacon.id, chair_id: self.id).order(:beacon_id).last(no_records).pluck(:value)
      var = data.last.variance
      sd = data.last.standard_deviation
      sigma = sd if index == 0

      if sigma < sd
        sigma = sd
      end

      v2[index, index] = var
      mean_sum += data.last.mean
      variance_sum += var
    end

    algorithm = self.algorithm
    if algorithm.present?
      kmeans = YAML::load(algorithm.serialized_class)
      first = (mean_sum/beacons.size)
      # one standard deviation away from first cluster
      variance_avg = (variance_sum/beacons.size)
      second = (first-3*Math::sqrt(variance_avg))
      kmeans.set_clusters([first, second])
      algorithm.algorithm_name = kmeans.algorithm_name
      algorithm.serialized_class = YAML::dump(kmeans)
      algorithm.save
    end

    if self.filter.present?
      if beacons.present? && beacons.size > 0
        h = Matrix.build(beacons.size, 1) { 1 }
        data.each_with_index do |d, i|
          data.each_with_index do |d2, j|
            if i != j
              v2[i, j] = d.cov(d2)
            end
          end
        end

        filter.V2 = v2
        filter.H = h
        # scalar = 10 - 4*sigma - 8
        filter.adjustment_threshold = threshold_function(sigma).round(2)
        filter.continuous_adjustment = false
        filter.save
      end
    end
  end

  def threshold_function sigma
    return (30.31776 - (6.681349/0.2202675)*(1 - Math::exp(-0.2202675*sigma)))
  end

  def perform_calibration_checks
    if self.calibration.finished?
      begin
        self.stop_calibration
        self.perform_calculations
        CalibrationData.where(chair_id: self.id).destroy_all
      rescue StandardError => ex
        Rails.logger.error ex.message
        Rails.logger.error ex.backtrace
        CalibrationData.where(chair_id: self.id).destroy_all
        self.calibration.update(calibrated: false)
      end
    end
  end

  def as_json(options = {})
    super(include: [:beacons, :calibration, :filter, :ground_truth]).merge({has_filter: has_filter, calibrated: calibrated?})
  end
end
