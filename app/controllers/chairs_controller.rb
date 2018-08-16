class ChairsController < ApplicationController
  before_action :set_chair, except: [:create]

  def create
    chair = Chair.create!(chair_params)

    render json: {chair: chair, status: 200}
  end

private 
  def set_chair
    @chair = Chair.find(params[:id])
  end

  def chair_params
    params.require(:chair).permit(:name, :notes)
  end
end