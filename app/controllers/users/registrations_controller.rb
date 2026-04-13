class Users::RegistrationsController < Devise::RegistrationsController

  private

  # Override to permit our custom fields (first_name, last_name etc.)
  def sign_up_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :phone_number,
      :password,
      :password_confirmation
    )
  end

  def account_update_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :email,
      :phone_number,
      :password,
      :password_confirmation,
      :current_password
    )
  end

  # After signup send customers to dashboard
  def after_sign_up_path_for(resource)
    resource.assign_role(Role::CUSTOMER)
    customer_dashboard_path
  end
end