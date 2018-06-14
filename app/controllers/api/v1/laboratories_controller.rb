class Api::V1::LaboratoriesController < Api::V1::BaseController
  before_action :authenticate_with_token!

  def index
		laboratories = current_user.laboratories
		render json: { laboratories: laboratories }, status: 200
  end

  def show
    laboratory = current_user.laboratories.find(params[:id])
    render json: laboratory, status: 200
  end

  def create
    laboratory = current_user.laboratories.build(laboratory_params)

    if laboratory.save
      render json: laboratory, status: 201
    else
      render json: { errors: laboratory.errors }, status: 422
    end
  end

  def update
    laboratory = current_user.laboratories.find(params[:id])

    if laboratory.update_attributes(laboratory_params)
      render json: laboratory, status: 200
    else
      render json: { errors: laboratory.errors }, status: 422
    end
  end

  def destroy
    laboratory = current_user.laboratories.find(params[:id])
    laboratory.destroy
    head 204
  end


  private

  def laboratory_params
    params.require(:laboratory).permit(:title, :description, :deadline, :done)
  end

end
