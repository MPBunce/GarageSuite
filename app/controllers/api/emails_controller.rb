class Api::EmailsController < Api::BaseController
  def create
    TenantMailer.notification(
      tenant: current_tenant,
      template: email_params[:template],
      data: email_params[:data].to_h.symbolize_keys
    ).deliver_later

    render json: { status: "queued" }, status: :accepted
  rescue TenantMailer::UnknownTemplate
    render json: { error: "Unknown template" }, status: :unprocessable_entity
  end

  private

  def email_params
    params.permit(:template, data: [ :recipient, :subject, :message ])
  end
end