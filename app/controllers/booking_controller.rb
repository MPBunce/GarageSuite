class BookingController < ApplicationController
  STEPS = %w[service vehicle datetime details].freeze

  def index
    # Start fresh or resume
    session[:booking] ||= {}
    @step     = "service"
    @services = Service.active.order(:name)
  end

  def update
    session[:booking] ||= {}
    current_step = params[:step]

    # Merge this step's data into the session
    session[:booking].merge!(booking_params_for(current_step))

    next_step = next_step_after(current_step)

    if next_step == "confirm"
      redirect_to booking_confirm_path
    else
      redirect_to booking_path(step: next_step)
    end
  end

  def confirm
    @booking  = session[:booking] || {}
    @service  = Service.find_by(id: @booking["service_id"])

    # Pre-fill if logged in
    if user_signed_in?
      @vehicles = current_user.vehicles.active
    end
  end

  def create
    @booking = session[:booking] || {}

    appointment = build_appointment_from_session(@booking)

    if appointment.save
      # Handle optional account creation
      if params[:create_account] == "1" && !user_signed_in?
        user = create_guest_account(appointment)
        if user&.persisted?
          appointment.claim!(user)
          sign_in(user)
          session.delete(:booking)
          redirect_to customer_appointments_path,
                      notice: "Booking confirmed and account created! Welcome."
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
      @errors = appointment.errors.full_messages
      render :confirm, status: :unprocessable_entity
    end
  end

  def lookup
    # Guest appointment lookup page
  end

  def result
    @appointment = Appointment.find_by(guest_token: params[:token])
    if @appointment.nil?
      redirect_to appointment_lookup_path,
                  alert: "Appointment not found."
    end
  end

  private

  def next_step_after(current_step)
    steps = STEPS
    current_index = steps.index(current_step)
    return "confirm" if current_index.nil? || current_index >= steps.length - 1
    steps[current_index + 1]
  end

  def booking_params_for(step)
    case step
    when "service"
      params.permit(:service_id).to_h
    when "vehicle"
      params.permit(:vehicle_id, :guest_vehicle_make, :guest_vehicle_model,
                    :guest_vehicle_year, :guest_vehicle_license).to_h
    when "datetime"
      params.permit(:scheduled_at).to_h
    when "details"
      params.permit(:guest_name, :guest_email, :guest_phone,
                    :customer_notes).to_h
    else
      {}
    end
  end

  def build_appointment_from_session(booking)
    appointment = Appointment.new(
      service_id:      booking["service_id"],
      scheduled_at:    booking["scheduled_at"],
      customer_notes:  booking["customer_notes"],
      status:          :pending
    )

    if user_signed_in?
      appointment.customer = current_user
      appointment.vehicle_id = booking["vehicle_id"] if booking["vehicle_id"].present?
    else
      appointment.guest_name  = booking["guest_name"]
      appointment.guest_email = booking["guest_email"]
      appointment.guest_phone = booking["guest_phone"]
    end

    # Guest vehicle details if no saved vehicle selected
    if booking["vehicle_id"].blank?
      appointment.guest_vehicle_make    = booking["guest_vehicle_make"]
      appointment.guest_vehicle_model   = booking["guest_vehicle_model"]
      appointment.guest_vehicle_year    = booking["guest_vehicle_year"]
      appointment.guest_vehicle_license = booking["guest_vehicle_license"]
    end

    appointment
  end

  def create_guest_account(appointment)
    User.create(
      first_name: appointment.guest_name.split.first,
      last_name:  appointment.guest_name.split.last || "-",
      email:      appointment.guest_email,
      phone_number: appointment.guest_phone,
      password:   params[:account_password],
      password_confirmation: params[:account_password_confirmation],
      active:     true
    ).tap { |u| u.assign_role(Role::CUSTOMER) if u.persisted? }
  end
end