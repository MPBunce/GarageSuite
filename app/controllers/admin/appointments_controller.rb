class Admin::AppointmentsController < Admin::BaseController
  before_action :set_appointment, only: [:show, :update, :destroy]

  def index
    @appointments = Appointment.all
                               .includes(:customer, :service, :vehicle)
                               .order(scheduled_at: :desc)
  end

  def show
  end

  def update
    case params[:action_type]
    when "confirm"
      @appointment.confirm!(current_user)
      redirect_to admin_appointment_path(@appointment),
                  notice: "Appointment confirmed."
    when "complete"
      @appointment.complete!
      redirect_to admin_appointment_path(@appointment),
                  notice: "Appointment marked as complete."
    when "cancel"
      @appointment.cancel!
      redirect_to admin_appointment_path(@appointment),
                  notice: "Appointment cancelled."
    else
      if @appointment.update(admin_appointment_params)
        redirect_to admin_appointment_path(@appointment),
                    notice: "Appointment updated."
      else
        render :show, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @appointment.destroy
    redirect_to admin_appointments_path,
                notice: "Appointment deleted."
  end

  private

  def set_appointment
    @appointment = Appointment.find(params[:id])
  end

  def admin_appointment_params
    params.require(:appointment).permit(
      :scheduled_at,
      :admin_notes
    )
  end
end