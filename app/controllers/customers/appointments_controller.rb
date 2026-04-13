class Customers::AppointmentsController < Customers::BaseController
  before_action :set_appointment, only: [:show, :destroy]

  def index
    @appointments = current_user.appointments
                                .includes(:service, :vehicle)
                                .order(scheduled_at: :desc)
  end

  def show
  end

  def new
    @appointment = Appointment.new
    @services    = Service.active
    @vehicles    = current_user.vehicles.active
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.customer = current_user
    @appointment.status   = :pending

    if @appointment.save
      redirect_to customer_appointments_path,
                  notice: "Appointment requested successfully!"
    else
      @services = Service.active
      @vehicles = current_user.vehicles.active
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    if @appointment.pending?
      @appointment.cancel!
      redirect_to customer_appointments_path,
                  notice: "Appointment cancelled."
    else
      redirect_to customer_appointments_path,
                  alert: "Only pending appointments can be cancelled."
    end
  end

  private

  def set_appointment
    @appointment = current_user.appointments.find(params[:id])
  end

  def appointment_params
    params.require(:appointment).permit(
      :service_id,
      :vehicle_id,
      :scheduled_at,
      :customer_notes
    )
  end
end