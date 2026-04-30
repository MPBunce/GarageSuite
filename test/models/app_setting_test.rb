require "test_helper"

class AppSettingTest < ActiveSupport::TestCase
  test "returns defaults for unset keys" do
    assert AppSetting.enabled?(:public_booking_enabled)
    assert_equal 10, AppSetting.value(:pending_appointments_warning_threshold)
    assert_equal "Auto Enterprise", AppSetting.value(:site_name)
  end

  test "updates mixed settings in bulk" do
    AppSetting.update_settings!(
      "public_booking_enabled" => "0",
      "pending_appointments_warning_threshold" => "25",
      "site_name" => "Auto Enterprise Pro"
    )

    assert_not AppSetting.enabled?(:public_booking_enabled)
    assert_equal 25, AppSetting.value(:pending_appointments_warning_threshold)
    assert_equal "Auto Enterprise Pro", AppSetting.value(:site_name)
  end
end