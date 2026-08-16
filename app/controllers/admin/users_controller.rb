class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :show, :update, :destroy ]

  def index
    @users = User.includes(:roles).order(:last_name)
  end

  def show
    @appointments = @user.appointments.includes(:service, :vehicle)
  end

  def update
    if @user.update(user_params)
      redirect_to admin_user_path(@user), notice: "User updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    @user.update(active: false)
    redirect_to admin_users_path, notice: "User deactivated."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:first_name, :last_name, :phone_number, :active)
  end
end
