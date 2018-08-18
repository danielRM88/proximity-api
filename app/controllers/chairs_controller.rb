class ChairsController < ApplicationController
  before_action :set_chair, except: [:index, :create]

  def index
    chairs = Chair.all.order(:name)

    render json: chairs, status: 200
  end

  def create
    chair = Chair.new(chair_params)

    if chair.save
      render json: {chair: chair, status: 200}
    else
      render json: {errors: chair.errors, status: 400}
    end
  end

  def show
    render json: @chair, status: 200
  end

  def update
    @chair.update(chair_params)

    render json: {beacon: @chair, status: 200}
  end

  def destroy
    @chair.destroy

    render json: {message: "chair deleted", status: 200}
  end

  def get_predictions
    chair_id = params[:id]
    limit = params[:limit]

    predictions = Prediction.where(chair_id: chair_id).order(:id).last(limit)

    render json: {predictions: predictions}, status: 200
  end

private 
  def set_chair
    @chair = Chair.find(params[:id])
  end

  def chair_params
    params.require(:chair).permit(:name, :notes, :apply_filter)
  end
end