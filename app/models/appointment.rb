class Appointment < ApplicationRecord
  enum :status, {
    pending:   0,
    confirmed: 1,
    completed: 2,
    cancelled: 3
  }

  # Associations
  belongs_to :customer,       class_name: "User",
                              foreign_key: "customer_id",
                              optional: true
  belongs_to :assigned_admin, class_name: "User",
                              foreign_key: "assigned_admin_id",
                              optional: true
  belongs_to :vehicle,        optional: true
  belongs_to :service

  # Validations — shared
  validates :scheduled_at, presence: true, unless: :pending?
  validates :service_id,   presence: true

  # Validations — guest vs logged in
  validate :must_have_customer_or_guest_details
  validate :must_have_vehicle_or_guest_vehicle
  validate :slot_must_have_capacity, if: :occupies_a_slot?

  # Guest token for lookup without account
  before_create :generate_guest_token, if: :guest?

  # Scopes
  scope :pending,   -> { where(status: :pending) }
  scope :confirmed, -> { where(status: :confirmed) }
  scope :completed, -> { where(status: :completed) }
  scope :cancelled, -> { where(status: :cancelled) }
  scope :upcoming,  -> { where("scheduled_at > ?", Time.current).order(:scheduled_at) }
  scope :guests,    -> { where(customer_id: nil) }
  scope :blocking,  -> { where(status: [ :pending, :confirmed ]).where.not(scheduled_at: nil) }

  # Status transitions
  def confirm!(admin)
    update!(status: :confirmed, assigned_admin_id: admin.id)
  end

  def complete!
    update!(status: :completed)
  end

  def cancel!
    update!(status: :cancelled)
  end

  # Guest helpers
  def guest?
    customer_id.nil?
  end

  def contact_name
    guest? ? guest_name : customer.full_name
  end

  def contact_email
    guest? ? guest_email : customer.email
  end

  def contact_phone
    guest? ? guest_phone : customer&.phone_number
  end

  def vehicle_display
    if vehicle.present?
      vehicle.display_name
    else
      "#{guest_vehicle_year} #{guest_vehicle_make} #{guest_vehicle_model}"
    end
  end

  # Claim a guest appointment when they create an account
  def claim!(user)
    update!(customer: user)
  end

  def ends_at
    return nil if scheduled_at.blank? || service.blank?

    scheduled_at + service.duration_minutes.minutes
  end

  private

  def occupies_a_slot?
    scheduled_at.present? && service.present? && !cancelled? && !completed?
  end

  def slot_must_have_capacity
    capacity = [ AppSetting.value("booking_capacity").to_i, 1 ].max
    finish = ends_at

    overlapping = Appointment.blocking
                             .includes(:service)
                             .where.not(id: id)
                             .where(scheduled_at: (scheduled_at - 1.day)...(finish + 1.day))
                             .count { |other| other.scheduled_at < finish && other.ends_at > scheduled_at }

    return if overlapping < capacity

    errors.add(:scheduled_at, "is already fully booked — please choose another time")
  end

  def must_have_customer_or_guest_details
    if customer_id.blank?
      errors.add(:guest_name,  "is required for guest bookings") if guest_name.blank?
      errors.add(:guest_email, "is required for guest bookings") if guest_email.blank?
    end
  end

  def must_have_vehicle_or_guest_vehicle
    if vehicle_id.blank?
      errors.add(:guest_vehicle_make,    "is required") if guest_vehicle_make.blank?
      errors.add(:guest_vehicle_model,   "is required") if guest_vehicle_model.blank?
      errors.add(:guest_vehicle_year,    "is required") if guest_vehicle_year.blank?
      errors.add(:guest_vehicle_license, "is required") if guest_vehicle_license.blank?
    end
  end

  def generate_guest_token
    self.guest_token = SecureRandom.urlsafe_base64(24)
  end
end
