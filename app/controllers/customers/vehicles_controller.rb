class Customers::VehiclesController < Customers::BaseController
  before_action :set_vehicle, only: [ :show, :destroy ]

  def index
    @vehicles = current_user.vehicles.active
  end

  def show
  end

  def new
    @vehicle = Vehicle.new
  end

  def create
    @vehicle = current_user.vehicles.build(vehicle_params)

    if @vehicle.save
      redirect_to customer_vehicles_path,
                  notice: "Vehicle added successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @vehicle.update(active: false)
    redirect_to customer_vehicles_path,
                notice: "Vehicle removed."
  end

  private

  def set_vehicle
    @vehicle = current_user.vehicles.find(params[:id])
  end

  def vehicle_params
    params.require(:vehicle).permit(
      :make,
      :model,
      :year,
      :license_plate,
      :vin
    )
  end
end
