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

  test "public booking redirects home when disabled" do
    AppSetting.update_settings!("public_booking_enabled" => "0")

    get booking_path

    assert_redirected_to root_path
  end
end