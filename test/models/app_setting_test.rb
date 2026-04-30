require "test_helper"

class AppSettingTest < ActiveSupport::TestCase
  test "returns defaults for unset keys" do
    assert AppSetting.enabled?(:public_booking_enabled)
    assert_equal 10, AppSetting.value(:pending_appointments_warning_threshold)
    assert_equal "Auto Enterprise", AppSetting.value(:site_name)
    assert_equal "Professional automotive services. Book your appointment online and let our team take care of the rest.", AppSetting.value(:homepage_description)
    assert_equal "(555) 123-4567", AppSetting.value(:contact_phone)
    assert_equal "service@autoenterprise.com", AppSetting.value(:contact_email)
  end

  test "updates mixed settings in bulk" do
    AppSetting.update_settings!(
      "public_booking_enabled" => "0",
      "pending_appointments_warning_threshold" => "25",
      "site_name" => "Auto Enterprise Pro",
      "homepage_description" => "Premium auto care for every vehicle.",
      "contact_phone" => "(555) 765-4321",
      "contact_email" => "help@autoenterprise.com"
    )

    assert_not AppSetting.enabled?(:public_booking_enabled)
    assert_equal 25, AppSetting.value(:pending_appointments_warning_threshold)
    assert_equal "Auto Enterprise Pro", AppSetting.value(:site_name)
    assert_equal "Premium auto care for every vehicle.", AppSetting.value(:homepage_description)
    assert_equal "(555) 765-4321", AppSetting.value(:contact_phone)
    assert_equal "help@autoenterprise.com", AppSetting.value(:contact_email)
  end
end