class Admin::ServicesController < Admin::BaseController
  before_action :set_service, only: [:show, :edit, :update, :destroy]

  def index
    @services = Service.all.order(:name)
  end

  def show
  end

  def new
    @service = Service.new
  end

  def create
    @service = Service.new(service_params)
    if @service.save
      redirect_to admin_services_path, notice: "Service created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @service.update(service_params)
      redirect_to admin_services_path, notice: "Service updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @service.update(active: false)
    redirect_to admin_services_path, notice: "Service deactivated."
  end

  private

  def set_service
    @service = Service.find(params[:id])
  end

  def service_params
    params.require(:service).permit(
      :name,
      :description,
      :duration_minutes,
      :price,
      :active
    )
  end
end