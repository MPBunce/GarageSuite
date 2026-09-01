require "test_helper"

class BookingAvailabilityFlowTest < ActionDispatch::IntegrationTest
  setup do
    @service = Service.create!(name: "Brake Inspection", duration_minutes: 60, price: 90, active: true)
    set_setting("hours_monday", "string", "09:00-12:00")
    set_setting("hours_sunday", "string", "")
    set_setting("booking_slot_interval_minutes", "integer", 60)
    set_setting("booking_min_notice_hours", "integer", 0)
    set_setting("booking_capacity", "integer", 1)
  end

  test "datetime step lists bookable times for an open day" do
    monday = Date.current.next_occurring(:monday)

    post booking_update_path, params: { step: "service", service_id: @service.id }
    get booking_path(step: "datetime", date: monday.to_fs(:iso8601))

    assert_response :success
    assert_select "input[name=scheduled_time][value=?]", "09:00"
    assert_select "input[name=scheduled_time][value=?]", "11:00"
  end

  test "datetime step reports no availability on a closed day" do
    sunday = Date.current.next_occurring(:sunday)

    post booking_update_path, params: { step: "service", service_id: @service.id }
    get booking_path(step: "datetime", date: sunday.to_fs(:iso8601))

    assert_response :success
    assert_select "input[name=scheduled_time]", count: 0
    assert_match "No times available", response.body
  end

  private

  def set_setting(key, type, value)
    setting = AppSetting.find_or_initialize_by(key: key)
    setting.assign_typed_value(value, type.to_sym)
    setting.save!
  end
end
