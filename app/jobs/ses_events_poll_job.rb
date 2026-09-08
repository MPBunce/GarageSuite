class SesEventsPollJob < ApplicationJob
  queue_as :background

  def perform
    queue_url = ENV.fetch("SES_EVENTS_QUEUE_URL")
    client = Aws::SQS::Client.new

    loop do
      response = client.receive_message(queue_url: queue_url, max_number_of_messages: 10, wait_time_seconds: 0)
      break if response.messages.empty?

      response.messages.each do |message|
        SesEventConsumer.process(JSON.parse(message.body))
        client.delete_message(queue_url: queue_url, receipt_handle: message.receipt_handle)
      rescue JSON::ParserError, KeyError => error
        Rails.logger.error("Invalid SES event: #{error.message}")
      end
    end
  end
end
