require "test_helper"

class Api::EmailsControllerTest < ActionDispatch::IntegrationTest
  test "queues an email for the tenant identified by API key" do
    tenant = Tenant.create!(domain: "example.test", display_name: "Example")

    assert_enqueued_emails 1 do
      post api_emails_path,
        headers: { "X-API-Key" => tenant.api_key },
        params: { template: "notification", data: { recipient: "recipient@example.test", subject: "Hello", message: "Welcome" } },
        as: :json
    end

    assert_response :accepted
  end

  test "rejects an unknown API key" do
    post api_emails_path, headers: { "X-API-Key" => "invalid" }, params: { email: {} }, as: :json

    assert_response :unauthorized
  end
end