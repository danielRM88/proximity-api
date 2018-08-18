class ChairsController < ApplicationController
  before_action :set_chair, except: [:create]

  def create
    chair = Chair.create!(chair_params)

    render json: {chair: chair, status: 200}
  end

  def show
    render json: @chair, status: 200
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
    params.require(:chair).permit(:name, :notes)
  end
end