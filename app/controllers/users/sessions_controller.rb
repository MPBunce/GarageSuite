class Users::SessionsController < Devise::SessionsController
  private

  # Override where Devise redirects after login
  def after_sign_in_path_for(resource)
    if current_user.admin?
      admin_dashboard_path
    else
      customer_dashboard_path
    end
  end

  # Override where Devise redirects after logout
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
