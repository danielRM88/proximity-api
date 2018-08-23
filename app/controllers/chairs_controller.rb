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

    predictions = Prediction.where(chair_id: @chair).order(:id).last(limit)
    last_prediction = predictions.last

    if last_prediction.present?
      seated = last_prediction.seated
    else
      seated = false
    end

    render json: {predictions: predictions, seated: seated}, status: 200
  end

  def get_kmeans_data
    limit = params[:limit]

    algorithm = @chair.algorithm
    data = []
    clusters = []
    seated = []
    not_seated = []
    if algorithm.present?
      kmeans = YAML::load(algorithm.serialized_class)
      clusters = kmeans.clusters.map{|c| c[:mean]}

      predictions = Prediction.where(chair_id: @chair).order(:id).last(limit)

      predictions.each do |p|
        if p.seated
          seated << p.algorithm_result
        else
          not_seated << p.algorithm_result
        end
      end

      # predictions = Prediction.where(chair_id: @chair).where(seated: false).order(:id).last(limit)

      # seated = predictions.map do |p|
      #   p.algorithm_result
      # end

      # predictions = Prediction.where(chair_id: @chair).where(seated: true).order(:id).last(limit)

      # not_seated = predictions.map do |p|
      #   p.algorithm_result
      # end

      data << ['', '', '', 'Cluster Means']
      if seated.size > not_seated.size
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

    render json: {chair_id: @chair.id, data: data}, status: 200
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

private 
  def set_chair
    @chair = Chair.find(params[:id])
  end

  def chair_params
    params.require(:chair).permit(:name, :notes, :apply_filter)
  end
end