class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  private

  def require_admin!
    unless current_user.admin_access?
      flash[:alert] = "Not authorized."
      redirect_to root_path
    end
  end

  def require_full_admin!
    return if current_user.admin?

    flash[:alert] = "Not authorized."
    redirect_to admin_dashboard_path
  end
end
