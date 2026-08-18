require "test_helper"

class AdminSettingsFlowTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    Role.find_or_create_by!(name: Role::ADMIN)
    Role.find_or_create_by!(name: Role::CUSTOMER)

    @admin = User.create!(
      first_name: "Admin",
      last_name: "User",
      email: "admin@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    @admin.assign_role(Role::ADMIN)
  end

  test "admin can update settings" do
    sign_in @admin, scope: :user

    patch admin_settings_path, params: {
      app_settings: {
        public_booking_enabled: "0",
        pending_appointments_warning_threshold: "18",
        site_name: "Auto Enterprise Plus"
      }
    }

    assert_redirected_to admin_settings_path
    follow_redirect!
    assert_match "Settings updated.", response.body
    assert_not AppSetting.enabled?(:public_booking_enabled)
    assert_equal 18, AppSetting.value(:pending_appointments_warning_threshold)
    assert_equal "Auto Enterprise Plus", AppSetting.value(:site_name)
  end

  test "signed-in user can edit their own profile" do
    customer = User.create!(
      first_name: "Jane",
      last_name: "Customer",
      email: "jane@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    customer.assign_role(Role::CUSTOMER)
    sign_in customer, scope: :user

    get edit_user_registration_path

    assert_response :success
    assert_includes response.body, "Edit Profile"

    patch user_registration_path, params: {
      user: {
        first_name: "Updated",
        last_name: "Customer",
        email: "jane.updated@example.com",
        phone_number: "555-0100",
        current_password: "password123"
      }
    }

    assert_redirected_to root_path
    customer.reload
    assert_equal "Updated", customer.first_name
    assert_equal "jane.updated@example.com", customer.email
    assert_equal "555-0100", customer.phone_number
  end

  test "public booking setting controls datetime step visibility" do
    AppSetting.update_settings!("public_booking_enabled" => "0")

    get booking_path(step: "datetime")

    assert_response :success
    assert_includes response.body, "Choose a Service"
    assert_not_includes response.body, "Choose Date & Time"

    AppSetting.update_settings!("public_booking_enabled" => "1")

    get booking_path(step: "datetime")

    assert_response :success
    assert_includes response.body, "Choose Date & Time"
  end
end
