class PagesController < ApplicationController
  def home
    @services = Service.active.order(:name)

    # Redirect already logged in users to their dashboard
    if user_signed_in?
      if current_user.admin?
        redirect_to admin_dashboard_path
      else
        redirect_to customer_dashboard_path
      end
    end
  end
end