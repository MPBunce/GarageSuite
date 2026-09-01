module Availability
  # Builds the list of bookable start times for a service on a given date,
  # honouring business hours, slot interval, notice period and bay capacity.
  class SlotFinder
    MIN_INTERVAL_MINUTES = 5

    def initialize(service:, date:, now: Time.current)
      @service = service
      @date = date
      @now = now
    end

    def call
      return [] if service.blank? || date.blank?

      window = BusinessHours.window_for(date)
      return [] if window.nil?

      candidate_starts(window).reject do |slot|
        slot < earliest_bookable_at || fully_booked?(slot)
      end
    end

    private

    attr_reader :service, :date, :now

    def candidate_starts(window)
      starts = []
      minutes = window.open_minutes

      while minutes + duration_minutes <= window.close_minutes
        starts << midnight + minutes.minutes
        minutes += interval_minutes
      end

      starts
    end

    def fully_booked?(slot)
      finish = slot + duration_minutes.minutes
      overlapping = existing_appointments.count do |appointment|
        appointment.scheduled_at < finish && appointment.ends_at > slot
      end

      overlapping >= capacity
    end

    def existing_appointments
      @existing_appointments ||= Appointment.blocking
                                            .includes(:service)
                                            .where(scheduled_at: (midnight - 1.day)...(midnight + 2.days))
                                            .to_a
    end

    def midnight
      @midnight ||= date.to_date.in_time_zone
    end

    def duration_minutes
      service.duration_minutes
    end

    def interval_minutes
      [ AppSetting.value("booking_slot_interval_minutes").to_i, MIN_INTERVAL_MINUTES ].max
    end

    def capacity
      [ AppSetting.value("booking_capacity").to_i, 1 ].max
    end

    def earliest_bookable_at
      now + AppSetting.value("booking_min_notice_hours").to_i.hours
    end
  end
end
