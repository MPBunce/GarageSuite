class BookingController < ApplicationController
  BASE_BOOKING_STEPS = %w[service vehicle details].freeze

  def index
    session[:booking] ||= {}
    @step = normalize_step(params[:step])
    @step_keys = booking_steps
    @account_creation_enabled = true
    @step_labels = @step_keys.map do |key|
      {
        "service" => "Service",
        "vehicle" => "Vehicle",
        "datetime" => "Date & Time",
        "details" => "Your Details"
      }.fetch(key)
    end

    case @step
    when "service"
      @services = Service.active.order(:name)
    when "vehicle"
      @vehicles = current_user.vehicles.active if user_signed_in?
    when "datetime"
      # nothing extra needed
    when "details"
      # nothing extra needed
    end
  end

  def update
    session[:booking] ||= {}
    current_step = normalize_step(params[:step])
    session[:booking].merge!(booking_params_for(current_step))
    next_step = next_step_after(current_step)

    if next_step == "confirm"
      redirect_to booking_confirm_path
    else
      redirect_to booking_path(step: next_step)
    end
  end

  def confirm
    @booking = session[:booking] || {}
    @service = Service.find_by(id: @booking["service_id"])
    @vehicles = current_user.vehicles.active if user_signed_in?
  end

  def create
    @booking = session[:booking] || {}

    appointment = build_appointment_from_session(@booking)

    if appointment.save
      if @booking["account_password"].present? && !user_signed_in?
        user = create_guest_account(appointment)
        if user&.persisted?
          # ── Create the vehicle under the new user's account ──
          vehicle = create_vehicle_for_user(user, @booking)

          # Link the vehicle to the appointment if it saved successfully
          if vehicle&.persisted?
            appointment.update(vehicle: vehicle)
          end

          appointment.claim!(user)
          sign_in(user)
          session.delete(:booking)
          redirect_to customer_appointments_path,
                      notice: "Booking confirmed and account created! Welcome, #{user.first_name}."
          return
        else
          session.delete(:booking)
          redirect_to appointment_result_path(token: appointment.guest_token),
                      alert: "Booking confirmed! However we couldn't create your account — #{user.errors.full_messages.join(', ')}."
          return
        end
      end

      session.delete(:booking)

      if user_signed_in?
        redirect_to customer_appointments_path,
                    notice: "Your appointment has been requested!"
      else
        redirect_to appointment_result_path(token: appointment.guest_token),
                    notice: "Booking confirmed! Save this page to track your appointment."
      end
    else
      @errors  = appointment.errors.full_messages
      @service = Service.find_by(id: @booking["service_id"])
      render :confirm, status: :unprocessable_entity
    end
  end

  def lookup
  end

  def result
    @appointment = Appointment.find_by(guest_token: params[:token])
    if @appointment.nil?
      redirect_to appointment_lookup_path, alert: "Appointment not found."
    end
  end

  private

  def booking_steps
    if AppSetting.enabled?(:public_booking_enabled)
      ["service", "vehicle", "datetime", "details"]
    else
      BASE_BOOKING_STEPS
    end
  end

  def normalize_step(step)
    value = step.to_s
    value = booking_steps.first if value.blank?
    booking_steps.include?(value) ? value : booking_steps.first
  end

  def next_step_after(current_step)
    current_index = booking_steps.index(current_step)
    return "confirm" if current_index.nil? || current_index >= booking_steps.length - 1
    booking_steps[current_index + 1]
  end

  def booking_params_for(step)
    case step
    when "service"
      params.permit(:service_id).to_h

    when "vehicle"
      params.permit(
        :vehicle_id,
        :guest_vehicle_make,
        :guest_vehicle_model,
        :guest_vehicle_year,
        :guest_vehicle_license
      ).to_h

    when "datetime"
      permitted = params.permit(:scheduled_date, :scheduled_time, :customer_notes).to_h
      date = permitted.delete("scheduled_date")
      time = permitted.delete("scheduled_time")

      if date.present? && time.present?
        begin
          scheduled_at = Time.zone.parse("#{date} #{time}")
          permitted["scheduled_at"] = scheduled_at if scheduled_at.present?
        rescue ArgumentError, TypeError
          # Keep value unset; the next step can prompt the user again.
        end
      end

      permitted

    when "details"
      params.permit(
        :guest_name,
        :guest_email,
        :guest_phone,
        :customer_notes,
        :account_password,
        :account_password_confirmation
      ).to_h.tap do |p|
        p["create_account"] = params[:create_account] == "1"
      end

    else
      {}
    end
  end

  def build_appointment_from_session(booking)
    appointment = Appointment.new(
      service_id:     booking["service_id"],
      scheduled_at:   booking["scheduled_at"],
      customer_notes: booking["customer_notes"],
      status:         :pending
    )

    if user_signed_in?
      appointment.customer   = current_user
      appointment.vehicle_id = booking["vehicle_id"] if booking["vehicle_id"].present?
    else
      appointment.guest_name  = booking["guest_name"]
      appointment.guest_email = booking["guest_email"]
      appointment.guest_phone = booking["guest_phone"]
    end

    if booking["vehicle_id"].blank?
      appointment.guest_vehicle_make    = booking["guest_vehicle_make"]
      appointment.guest_vehicle_model   = booking["guest_vehicle_model"]
      appointment.guest_vehicle_year    = booking["guest_vehicle_year"]
      appointment.guest_vehicle_license = booking["guest_vehicle_license"]
    end

    appointment
  end

  def create_guest_account(appointment)
    name_parts = appointment.guest_name.to_s.split(" ", 2)

    user = User.new(
      first_name:            name_parts[0] || "Guest",
      last_name:             name_parts[1] || "-",
      email:                 appointment.guest_email,
      phone_number:          appointment.guest_phone,
      password:              @booking["account_password"],
      password_confirmation: @booking["account_password_confirmation"],
      active:                true
    )

    if user.save
      user.assign_role(Role::CUSTOMER)
      user
    else
      user
    end
  end

  def create_vehicle_for_user(user, booking)
    return nil if booking["guest_vehicle_make"].blank?    ||
                  booking["guest_vehicle_model"].blank?   ||
                  booking["guest_vehicle_year"].blank?    ||
                  booking["guest_vehicle_license"].blank?

    vehicle = Vehicle.new(
      user:          user,
      make:          booking["guest_vehicle_make"],
      model:         booking["guest_vehicle_model"],
      year:          booking["guest_vehicle_year"].to_i,
      license_plate: booking["guest_vehicle_license"],
      active:        true
    )

    if vehicle.save
      vehicle
    else
      Rails.logger.warn "Could not save vehicle for user #{user.id}: #{vehicle.errors.full_messages.join(', ')}"
      nil
    end
  end

end