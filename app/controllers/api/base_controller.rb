class Api::BaseController < ActionController::API
  before_action :authenticate_tenant!

  private

  attr_reader :current_tenant

  def authenticate_tenant!
    @current_tenant = Tenant.find_by(api_key: request.headers["X-API-Key"])
    render json: { error: "Unauthorized" }, status: :unauthorized unless @current_tenant
  end
end
