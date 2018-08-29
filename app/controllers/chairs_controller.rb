class ChairsController < ApplicationController
  before_action :set_chair, except: [:index, :create]

  def index
    chairs = Chair.all.order(:name)

    render json: chairs, status: 200
  end

  def create
    chair = Chair.new(chair_params)

    if chair.save
      render json: {chair: chair}, status: 200
    else
      render json: {errors: chair.errors}, status: 400
    end
  end

  def show
    render json: @chair, status: 200
  end

  def update
    result = @chair.update(chair_params)

    if result
      render json: {beacon: @chair}, status: 200
    else
      render json: {errors: @chair.errors}, status: 400
    end
  end

  def destroy
    result = @chair.destroy

    if result
      render json: {message: "chair deleted"}, status: 200
    else
      render json: {errors: @chair.errors}, status: 400
    end
  end

  def get_predictions
    limit = params[:limit]

    predictions = Prediction.where(chair_id: @chair.id).order(:id).last(limit)
    last_prediction = predictions.last

    if last_prediction.present?
      seated = last_prediction.seated
    else
      seated = false
    end

    performance = @chair.performance

    render json: {predictions: predictions, seated: seated, performance: performance}, status: 200
  end

  def get_kmeans_data
    limit = params[:limit]

    algorithm = @chair.algorithm
    data = []
    clusters = []
    seated = []
    not_seated = []
    pred_seated = false
    if algorithm.present?
      kmeans = YAML::load(algorithm.serialized_class)
      clusters = kmeans.clusters.map{|c| c[:mean]}

      predictions = Prediction.where(chair_id: @chair).order(:id).last(limit)
      last_prediction = predictions.last
      pred_seated = last_prediction.seated if last_prediction.present?

      predictions.each do |p|
        if p.seated
          seated << p.algorithm_result
        else
          not_seated << p.algorithm_result
        end
      end

      data << ['', '', '', 'Cluster Means'] if seated.size > 0 || not_seated.size > 0
      if clusters.size > seated.size && clusters.size > not_seated.size
        clusters.each_with_index do |value, index|
          v1 = seated[index]
          v1 = 0 if (v1.blank? && index == 0)
          v2 = not_seated[index]
          v2 = 0 if (v2.blank? && index == 0)
          data << [0, v1, v2, value]
        end
      elsif seated.size > not_seated.size
        seated.each_with_index do |value, index|
          v = not_seated[index]
          v = 0 if (v.blank? && index == 0)
          data << [0, value, v, clusters[index]]
        end
      else
        not_seated.each_with_index do |value, index|
          v = seated[index]
          v = 0 if (v.blank? && index == 0)
          data << [0, v, value, clusters[index]]
        end
      end
    end

    performance = @chair.performance

    render json: {chair_id: @chair.id, data: data, seated: pred_seated, performance: performance}, status: 200
  end

  def fetch_calibration_progress
    progress = @chair.get_calibration_progress

    render json: {progress: progress, calibrated: @chair.calibrated?, ongoing: @chair.ongoing_calibration?}, status: 200
  end

  def start_calibration
    calibration = params[:calibration]
    result = @chair.start_calibration calibration[:records_to_calibrate]

    if result
      render json: {chair: @chair}, status: 200
    else
      render json: {errors: @chair.calibration.errors}, status: 400
    end
  end

  def stop_calibration
    @chair.stop_calibration

    render json: {message: "Calibration stopped"}, status: 200
  end

  def update_filter_process_noise
    filter = @chair.filter
    process_error = params[:process_error]
    continuous_adjustment = params[:continuous_adjustment]
    adjustment_threshold = params[:adjustment_threshold]
    result = false

    if filter.present? && 
      process_error.present?
      filter.V1 = Matrix[[process_error.to_f]]
      filter.continuous_adjustment = continuous_adjustment if !continuous_adjustment.nil?
      filter.adjustment_threshold = adjustment_threshold if adjustment_threshold.present?
      result = filter.save
    end
    if result
      render json: {chair: @chair}, status: 200
    else
      if filter.present?
        render json: {errors: filter.errors}, status: 400
      else
        render json: {errors: "Chair does not have a filter"}, status: 404
      end
    end
  end

  def update_ground_truth
    ground_truth_params = params[:ground_truth]
    ground_truth = @chair.ground_truth
    result = false

    ground_truth = GroundTruth.create(chair: @chair) if ground_truth.blank?
    ground_truth.active = ground_truth_params[:active]
    ground_truth.seated = ground_truth_params[:seated]
    ground_truth.gender = ground_truth_params[:gender]
    ground_truth.height = ground_truth_params[:height]
    ground_truth.weight = ground_truth_params[:weight]
    result = ground_truth.save

    if result
      render json: {chair: @chair}, status: 200
    else
      render json: {errors: ground_truth.errors}, status: 400
    end
  end

private 
  def set_chair
    @chair = Chair.find(params[:id])
  end

  def chair_params
    params.require(:chair).permit(:name, :notes, :apply_filter)
  end
end