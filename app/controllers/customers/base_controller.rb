class Customers::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_customer!

  private

  def require_customer!
    unless current_user.customer?
      flash[:alert] = "Not authorized."
      redirect_to root_path
    end
  end
end