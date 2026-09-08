class Admin::AppointmentsController < Admin::BaseController
  before_action :set_appointment, only: [ :show, :update, :destroy ]
  before_action :require_full_admin!, only: [ :update, :destroy ]

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
      scheduled_at = params.dig(:appointment, :scheduled_at)

      if scheduled_at.blank?
        scheduled_date = params.dig(:appointment, :scheduled_date)
        scheduled_time = params.dig(:appointment, :scheduled_time)

        if scheduled_date.present? && scheduled_time.present?
          est = ActiveSupport::TimeZone["Eastern Time (US & Canada)"]
          scheduled_at = est.parse("#{scheduled_date} #{scheduled_time}")
        end
      end

      if scheduled_at.blank?
        @appointment.errors.add(:scheduled_at, "date and time must be selected before confirming")
        render :show, status: :unprocessable_entity
        return
      end

      unless @appointment.update(scheduled_at: scheduled_at)
        render :show, status: :unprocessable_entity
        return
      end

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
