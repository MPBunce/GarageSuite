class Customers::DashboardController < Customers::BaseController
  def index
    @upcoming_appointments = current_user.appointments
                                         .includes(:service, :vehicle)
                                         .upcoming
                                         .limit(5)
    @vehicles = current_user.vehicles.active
  end
end
