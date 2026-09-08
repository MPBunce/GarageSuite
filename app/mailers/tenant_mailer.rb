class TenantMailer < ApplicationMailer
  class UnknownTemplate < StandardError; end

  def notification(tenant:, template:, data:)
    raise UnknownTemplate unless template.to_s == "notification"

    @tenant = tenant
    @data = data
    mail(
      from: "noreply@yourservice.com",
      reply_to: tenant.reply_to.presence || "noreply@yourservice.com",
      subject: data.fetch(:subject),
      to: data.fetch(:recipient)
    )
  end
end
