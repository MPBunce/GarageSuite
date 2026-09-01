class AppSetting < ApplicationRecord
  DEFINITION_GROUPS = {
    "Branding" => [
      {
        key: "site_name",
        label: "Site name",
        description: "Displayed in the browser title and primary navigation brand.",
        type: :string,
        default: "Auto Enterprise"
      },
      {
        key: "homepage_description",
        label: "Homepage description",
        description: "Displayed in the hero section on the public homepage.",
        type: :string,
        default: "Professional automotive services. Book your appointment online and let our team take care of the rest."
      },
      {
        key: "contact_phone",
        label: "Contact phone",
        description: "Displayed in the public contact section on the homepage.",
        type: :string,
        default: "(555) 123-4567"
      },
      {
        key: "contact_email",
        label: "Contact email",
        description: "Displayed in the public contact section on the homepage.",
        type: :string,
        default: "service@autoenterprise.com"
      },
      {
        key: "instagram_username",
        label: "Instagram username",
        description: "Displayed in the public contact section when provided.",
        type: :string,
        default: ""
      },
      {
        key: "x_username",
        label: "X username",
        description: "Displayed in the public contact section when provided.",
        type: :string,
        default: ""
      },
      {
        key: "tiktok_username",
        label: "TikTok username",
        description: "Displayed in the public contact section when provided.",
        type: :string,
        default: ""
      },
      {
        key: "root_url",
        label: "Root URL",
        description: "The root domain used for www redirect (e.g. example.ca).",
        type: :string,
        default: "example.ca"
      }
    ],
    "Operations" => [
      {
        key: "public_booking_enabled",
        label: "Public booking enabled",
        description: "Allow public customers to choose a preferred date and time while booking. When off, staff assign scheduling.",
        type: :boolean,
        default: true
      },
      {
        key: "pending_appointments_warning_threshold",
        label: "Pending warning threshold",
        description: "Show a warning banner in dashboard when pending appointments meet this value.",
        type: :integer,
        default: 10
      },
      {
        key: "booking_capacity",
        label: "Concurrent capacity",
        description: "How many appointments can run at the same time (service bays or technicians).",
        type: :integer,
        default: 1
      },
      {
        key: "booking_slot_interval_minutes",
        label: "Slot interval (minutes)",
        description: "Spacing between the appointment start times offered to customers.",
        type: :integer,
        default: 30
      },
      {
        key: "booking_min_notice_hours",
        label: "Minimum notice (hours)",
        description: "How far ahead a customer must book. Slots sooner than this are hidden.",
        type: :integer,
        default: 2
      },
      {
        key: "booking_max_advance_days",
        label: "Booking window (days)",
        description: "How many days into the future customers may book.",
        type: :integer,
        default: 60
      }
    ],
    "Business Hours" => [
      { key: "hours_monday",    label: "Monday",    default: "08:00-17:00" },
      { key: "hours_tuesday",   label: "Tuesday",   default: "08:00-17:00" },
      { key: "hours_wednesday", label: "Wednesday", default: "08:00-17:00" },
      { key: "hours_thursday",  label: "Thursday",  default: "08:00-17:00" },
      { key: "hours_friday",    label: "Friday",    default: "08:00-17:00" },
      { key: "hours_saturday",  label: "Saturday",  default: "09:00-14:00" },
      { key: "hours_sunday",    label: "Sunday",    default: "" }
    ].map do |definition|
      definition.merge(
        description: "Opening hours as 24h range, e.g. 08:00-17:00. Leave blank when closed.",
        type: :string,
        format: :time_range
      )
    end
  }.freeze

  TIME_RANGE_FORMAT = /\A([01]\d|2[0-3]):[0-5]\d-([01]\d|2[0-3]):[0-5]\d\z/

  DEFINITIONS = DEFINITION_GROUPS.values.flatten.index_by { |definition| definition[:key] }.freeze

  validates :key, presence: true,
                  uniqueness: true,
                  inclusion: { in: DEFINITIONS.keys }
  validates :value_type, inclusion: { in: %w[boolean integer string] }
  validate :value_matches_type
  validate :value_matches_format

  scope :ordered, -> { order(:key) }

  def self.definition_groups
    DEFINITION_GROUPS
  end

  def self.definition_for(key)
    DEFINITIONS.fetch(key.to_s)
  end

  def self.default_for(key)
    definition_for(key)[:default]
  end

  def self.value(key)
    definition = definition_for(key)
    setting = find_by(key: key.to_s)
    return definition[:default] if setting.nil?

    setting.typed_value
  end

  def self.enabled?(key)
    definition = definition_for(key)
    raise ArgumentError, "#{key} is not a boolean setting" unless definition[:type] == :boolean

    ActiveModel::Type::Boolean.new.cast(value(key))
  end

  def self.value_map
    stored = where(key: DEFINITIONS.keys).index_by(&:key)

    DEFINITIONS.each_with_object({}) do |(key, definition), values|
      values[key] = stored.key?(key) ? stored[key].typed_value : definition[:default]
    end
  end

  def self.update_settings!(settings_params)
    submitted = settings_params.to_h

    transaction do
      DEFINITIONS.each do |key, definition|
        setting = find_or_initialize_by(key: key)
        raw_value = submitted.key?(key) ? submitted[key] : definition[:default]
        typed = cast_value(raw_value, definition[:type])
        setting.assign_typed_value(typed, definition[:type])
        setting.save!
      end
    end
  end

  def typed_value
    case value_type
    when "boolean"
      value_boolean
    when "integer"
      value_integer
    when "string"
      value_string
    else
      nil
    end
  end

  def assign_typed_value(value, type)
    self.value_type = type.to_s
    self.value_boolean = nil
    self.value_integer = nil
    self.value_string = nil

    case type
    when :boolean
      self.value_boolean = ActiveModel::Type::Boolean.new.cast(value)
    when :integer
      self.value_integer = value.to_i
    when :string
      self.value_string = value.to_s
    end
  end

  def self.cast_value(value, type)
    case type
    when :boolean
      ActiveModel::Type::Boolean.new.cast(value)
    when :integer
      value.to_i
    when :string
      value.to_s
    else
      value
    end
  end

  private

  def value_matches_type
    case value_type
    when "boolean"
      errors.add(:value_boolean, "must be true or false") unless [ true, false ].include?(value_boolean)
    when "integer"
      errors.add(:value_integer, "must be present") if value_integer.nil?
    when "string"
      errors.add(:value_string, "must be present") if value_string.nil?
    end
  end

  def value_matches_format
    definition = DEFINITIONS[key.to_s]
    return if definition.nil? || definition[:format] != :time_range
    return if value_string.blank?

    unless value_string.match?(TIME_RANGE_FORMAT)
      errors.add(:value_string, "must be blank when closed, or a 24h range like 08:00-17:00")
      return
    end

    opens, closes = value_string.split("-")
    errors.add(:value_string, "closing time must be after opening time") if closes <= opens
  end
end
