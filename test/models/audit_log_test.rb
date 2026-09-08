require "test_helper"

class AuditLogTest < ActiveSupport::TestCase
  test "records changes with the current actor" do
    actor = create_user

    Current.set(actor: actor) do
      service = Service.create!(name: "Audit Test", duration_minutes: 30, price: 25)
      service.update!(price: 30)
    end

    logs = AuditLog.where(auditable_type: "Service").order(:created_at)
    assert_equal [ "create", "update" ], logs.pluck(:action)
    assert_equal actor, logs.last.actor
    assert_equal [ "25.0", "30.0" ], logs.last.changeset.fetch("price")
  end
end