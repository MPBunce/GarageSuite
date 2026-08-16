class Admin::DashboardController < Admin::BaseController
  def index
    @pending_warning_threshold = AppSetting.value(:pending_appointments_warning_threshold)
    @pending_appointments   = Appointment.pending
                                         .includes(:customer, :service, :vehicle)
                                         .order(scheduled_at: :asc)
    @confirmed_appointments = Appointment.confirmed
                                         .includes(:customer, :service, :vehicle)
                                         .order(scheduled_at: :asc)
    @show_pending_warning = @pending_appointments.size >= @pending_warning_threshold
    @total_customers        = User.customers.count
    @total_services         = Service.active.count
  end
end
