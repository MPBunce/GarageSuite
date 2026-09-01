require "test_helper"

class BusinessHoursTest < ActiveSupport::TestCase
  test "parses a valid range into minutes" do
    window = BusinessHours.parse("08:30-17:00")

    assert_equal 510, window.open_minutes
    assert_equal 1020, window.close_minutes
  end

  test "treats blank and malformed values as closed" do
    assert_nil BusinessHours.parse("")
    assert_nil BusinessHours.parse(nil)
    assert_nil BusinessHours.parse("not-hours")
    assert_nil BusinessHours.parse("17:00-08:00")
    assert_nil BusinessHours.parse("25:00-26:00")
  end

  test "maps each weekday to its setting key" do
    assert_equal "hours_monday", BusinessHours.setting_key_for(Date.new(2026, 8, 31))
    assert_equal "hours_sunday", BusinessHours.setting_key_for(Date.new(2026, 8, 30))
  end

  test "reads the window from settings" do
    AppSetting.create!(key: "hours_monday", value_type: "string", value_string: "09:00-12:00")

    window = BusinessHours.window_for(Date.new(2026, 8, 31))

    assert_equal 540, window.open_minutes
    assert_equal 720, window.close_minutes
  end
end
