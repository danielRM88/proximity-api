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

    render json: {predictions: predictions}, status: 200
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