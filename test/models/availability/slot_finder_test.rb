require "test_helper"

class Availability::SlotFinderTest < ActiveSupport::TestCase
  setup do
    @monday = Date.new(2026, 8, 31)
    @now = Time.zone.local(2026, 8, 28, 9, 0)
    @service = Service.create!(name: "Tire Rotation", duration_minutes: 60, price: 50, active: true)

    set_setting("hours_monday", "string", "09:00-12:00")
    set_setting("hours_sunday", "string", "")
    set_setting("booking_slot_interval_minutes", "integer", 60)
    set_setting("booking_capacity", "integer", 1)
    set_setting("booking_min_notice_hours", "integer", 0)
  end

  test "generates slots inside business hours that fit the service duration" do
    slots = find_slots(@monday)

    assert_equal [ "09:00", "10:00", "11:00" ], slots.map { |slot| slot.strftime("%H:%M") }
  end

  test "returns nothing on a closed day" do
    assert_empty find_slots(Date.new(2026, 8, 30))
  end

  test "hides slots taken up to capacity" do
    book_at(Time.zone.local(2026, 8, 31, 10, 0))

    assert_equal [ "09:00", "11:00" ], find_slots(@monday).map { |slot| slot.strftime("%H:%M") }
  end

  test "keeps a slot open while capacity remains" do
    set_setting("booking_capacity", "integer", 2)
    book_at(Time.zone.local(2026, 8, 31, 10, 0))

    assert_includes find_slots(@monday).map { |slot| slot.strftime("%H:%M") }, "10:00"
  end

  test "ignores cancelled appointments" do
    appointment = book_at(Time.zone.local(2026, 8, 31, 10, 0))
    appointment.cancel!

    assert_includes find_slots(@monday).map { |slot| slot.strftime("%H:%M") }, "10:00"
  end

  test "respects the minimum notice period" do
    set_setting("booking_min_notice_hours", "integer", 2)
    now = Time.zone.local(2026, 8, 31, 8, 30)

    slots = Availability::SlotFinder.new(service: @service, date: @monday, now: now).call

    assert_equal [ "11:00" ], slots.map { |slot| slot.strftime("%H:%M") }
  end

  test "blocks slots using each existing appointment's own duration" do
    set_setting("booking_slot_interval_minutes", "integer", 30)
    long_service = Service.create!(name: "Alignment", duration_minutes: 45, price: 120, active: true)
    short_service = Service.create!(name: "Top Up", duration_minutes: 30, price: 20, active: true)

    # 09:30–10:15 booked, so a 30 minute service cannot start at 09:30 or 10:00.
    book_at(Time.zone.local(2026, 8, 31, 9, 30), service: long_service)

    slots = Availability::SlotFinder.new(service: short_service, date: @monday, now: @now).call

    assert_equal [ "09:00", "10:30", "11:00", "11:30" ], slots.map { |slot| slot.strftime("%H:%M") }
  end

  test "only offers start times where the service fits before closing" do
    set_setting("booking_slot_interval_minutes", "integer", 30)
    long_service = Service.create!(name: "Full Detail", duration_minutes: 120, price: 300, active: true)

    slots = Availability::SlotFinder.new(service: long_service, date: @monday, now: @now).call

    assert_equal [ "09:00", "09:30", "10:00" ], slots.map { |slot| slot.strftime("%H:%M") }
  end

  private

  def find_slots(date)
    Availability::SlotFinder.new(service: @service, date: date, now: @now).call
  end

  def book_at(time, service: @service)
    Appointment.create!(
      service: service,
      scheduled_at: time,
      status: :confirmed,
      guest_name: "Guest",
      guest_email: "guest@example.com",
      guest_vehicle_make: "Honda",
      guest_vehicle_model: "Civic",
      guest_vehicle_year: 2020,
      guest_vehicle_license: "ABC123"
    )
  end

  def set_setting(key, type, value)
    setting = AppSetting.find_or_initialize_by(key: key)
    setting.assign_typed_value(value, type.to_sym)
    setting.save!
  end
end
