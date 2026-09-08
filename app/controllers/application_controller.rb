class ApplicationController < ActionController::Base
  include Pundit::Authorization

  around_action :set_audit_actor

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_back(fallback_location: root_path)
  end

  def set_audit_actor
    Current.set(actor: current_user) { yield }
  end
end
