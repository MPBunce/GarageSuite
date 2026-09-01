require "test_helper"

class AppointmentTest < ActiveSupport::TestCase
  setup do
    @service = Service.create!(name: "Oil Change", duration_minutes: 60, price: 80, active: true)
    set_capacity(1)
  end

  test "ends_at uses the service duration" do
    appointment = build_at(Time.zone.local(2026, 8, 31, 9, 0))

    assert_equal Time.zone.local(2026, 8, 31, 10, 0), appointment.ends_at
  end

  test "rejects an overlapping appointment when capacity is full" do
    build_at(Time.zone.local(2026, 8, 31, 9, 0)).save!
    overlapping = build_at(Time.zone.local(2026, 8, 31, 9, 30))

    assert_not overlapping.valid?
    assert_includes overlapping.errors[:scheduled_at].join, "fully booked"
  end

  test "allows a back to back appointment" do
    build_at(Time.zone.local(2026, 8, 31, 9, 0)).save!

    assert build_at(Time.zone.local(2026, 8, 31, 10, 0)).valid?
  end

  test "allows overlap while capacity remains" do
    set_capacity(2)
    build_at(Time.zone.local(2026, 8, 31, 9, 0)).save!

    assert build_at(Time.zone.local(2026, 8, 31, 9, 30)).valid?
  end

  test "cancelled appointments free up their slot" do
    build_at(Time.zone.local(2026, 8, 31, 9, 0)).tap(&:save!).cancel!

    assert build_at(Time.zone.local(2026, 8, 31, 9, 30)).valid?
  end

  test "an existing appointment stays valid when saved again" do
    appointment = build_at(Time.zone.local(2026, 8, 31, 9, 0))
    appointment.save!

    assert appointment.valid?
  end

  test "overlap is measured against each appointment's own duration" do
    quick = Service.create!(name: "Tire Plug", duration_minutes: 30, price: 25, active: true)
    build_at(Time.zone.local(2026, 8, 31, 9, 0)).save!

    # The 60 minute booking runs to 10:00, so a 30 minute job at 09:45 conflicts.
    assert_not build_at(Time.zone.local(2026, 8, 31, 9, 45), service: quick).valid?
    assert build_at(Time.zone.local(2026, 8, 31, 10, 0), service: quick).valid?
  end

  private

  def build_at(time, service: @service)
    Appointment.new(
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

  def set_capacity(value)
    setting = AppSetting.find_or_initialize_by(key: "booking_capacity")
    setting.assign_typed_value(value, :integer)
    setting.save!
  end
end
