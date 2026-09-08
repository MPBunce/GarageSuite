class SesEventConsumer
  def self.process(sns_message)
    event = JSON.parse(sns_message.fetch("Message"))
    notification = event.fetch("notification")
    status = case notification.fetch("notificationType")
    when "Bounce" then "bounce"
    when "Complaint" then "complaint"
    else return
    end

    recipients = event.fetch("mail").fetch("destination")
    Current.set(actor: User.system_account) do
      User.where(email: recipients).find_each do |user|
        user.update!(email_valid: false, email_status: status)
      end
    end
  end
end
