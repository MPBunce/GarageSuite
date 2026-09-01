# Reads the per-day opening hours stored in AppSetting ("hours_monday", ...).
class BusinessHours
  Window = Struct.new(:open_minutes, :close_minutes)

  SETTING_KEY_BY_WDAY = {
    0 => "hours_sunday",
    1 => "hours_monday",
    2 => "hours_tuesday",
    3 => "hours_wednesday",
    4 => "hours_thursday",
    5 => "hours_friday",
    6 => "hours_saturday"
  }.freeze

  def self.setting_key_for(date)
    SETTING_KEY_BY_WDAY.fetch(date.wday)
  end

  def self.window_for(date)
    parse(AppSetting.value(setting_key_for(date)))
  end

  def self.open_on?(date)
    window_for(date).present?
  end

  def self.display_for(date)
    window = window_for(date)
    return "Closed" if window.nil?

    "#{format_minutes(window.open_minutes)} – #{format_minutes(window.close_minutes)}"
  end

  def self.parse(raw)
    return nil if raw.blank?

    opens, closes = raw.to_s.split("-", 2)
    open_minutes  = to_minutes(opens)
    close_minutes = to_minutes(closes)
    return nil if open_minutes.nil? || close_minutes.nil? || close_minutes <= open_minutes

    Window.new(open_minutes, close_minutes)
  end

  def self.to_minutes(value)
    match = /\A(\d{1,2}):(\d{2})\z/.match(value.to_s.strip)
    return nil if match.nil?

    hours   = match[1].to_i
    minutes = match[2].to_i
    return nil if hours > 23 || minutes > 59

    (hours * 60) + minutes
  end

  def self.format_minutes(minutes)
    Time.zone.parse("00:00").advance(minutes: minutes).strftime("%-l:%M %p")
  end
end
