require "test_helper"

class UserTest < ActiveSupport::TestCase
  setup do
    role(Role::ADMIN)
    role(Role::CUSTOMER)
  end

  test "requires a first and last name" do
    user = User.new(email: "no-name@example.com", password: "password123")

    assert_not user.valid?
    assert_includes user.errors[:first_name], "can't be blank"
    assert_includes user.errors[:last_name], "can't be blank"
  end

  test "full_name joins first and last name" do
    assert_equal "Ada Lovelace", create_user(first_name: "Ada", last_name: "Lovelace").full_name
  end

  test "downcases the email before saving" do
    user = create_user(email: "MixedCase@Example.COM")

    assert_equal "mixedcase@example.com", user.reload.email
  end

  test "accepts common phone number formats" do
    [ "+1 555 010 0001", "555-010-0001", "(555) 010 0001", "5550100001" ].each do |phone|
      assert create_user(phone_number: phone).valid?, "expected #{phone} to be valid"
    end
  end

  test "rejects malformed phone numbers but allows blank" do
    user = create_user

    user.phone_number = "not-a-phone"
    assert_not user.valid?

    user.phone_number = "12345"
    assert_not user.valid?

    user.phone_number = ""
    assert user.valid?

    user.phone_number = nil
    assert user.valid?
  end

  test "assign_role grants the role once" do
    user = create_user

    user.assign_role(Role::ADMIN)
    user.assign_role(Role::ADMIN)

    assert user.admin?
    assert_equal 1, user.roles.count
  end

  test "assign_role is case insensitive" do
    user = create_user
    user.assign_role("ADMIN")

    assert user.admin?
  end

  test "assign_role raises for an unknown role" do
    assert_raises(ActiveRecord::RecordNotFound) { create_user.assign_role("wizard") }
  end

  test "remove_role revokes the role" do
    user = create_customer
    user.remove_role(Role::CUSTOMER)

    assert_not user.reload.customer?
  end

  test "role predicates are independent" do
    customer = create_customer

    assert customer.customer?
    assert_not customer.admin?
  end

  test "admins and customers scopes select by role" do
    admin = create_admin
    customer = create_customer

    assert_includes User.admins, admin
    assert_not_includes User.admins, customer
    assert_includes User.customers, customer
    assert_not_includes User.customers, admin
  end

  test "active scope excludes deactivated users" do
    inactive = create_user(active: false)

    assert_not_includes User.active, inactive
  end

  test "destroying a user removes their role assignments" do
    user = create_customer

    assert_difference "UserRole.count", -1 do
      user.destroy
    end
  end

  test "destroying an admin nullifies their managed appointments" do
    admin = create_admin
    service = Service.create!(name: "Nullify Check", duration_minutes: 30, price: 40, active: true)
    appointment = Appointment.create!(
      service: service,
      assigned_admin: admin,
      guest_name: "Guest",
      guest_email: "guest@example.com",
      guest_vehicle_make: "Honda",
      guest_vehicle_model: "Civic",
      guest_vehicle_year: 2020,
      guest_vehicle_license: "NULL-1"
    )

    admin.destroy

    assert_nil appointment.reload.assigned_admin_id
  end
end
