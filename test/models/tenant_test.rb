require "test_helper"

class TenantTest < ActiveSupport::TestCase
  test "generates an API key" do
    tenant = Tenant.create!(domain: "example.test")

    assert_predicate tenant.api_key, :present?
  end
end