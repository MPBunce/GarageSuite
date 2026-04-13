class Admin::DashboardController < Admin::BaseController
  def index
    @pending_appointments   = Appointment.pending
                                         .includes(:customer, :service, :vehicle)
                                         .order(scheduled_at: :asc)
    @confirmed_appointments = Appointment.confirmed
                                         .includes(:customer, :service, :vehicle)
                                         .order(scheduled_at: :asc)
    @total_customers        = User.customers.count
    @total_services         = Service.active.count
  end
end