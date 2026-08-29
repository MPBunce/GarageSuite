module ApplicationHelper
  SOCIAL_PROFILE_URLS = {
    instagram: "https://www.instagram.com/",
    x: "https://x.com/",
    tiktok: "https://www.tiktok.com/@"
  }.freeze

  def site_name
    AppSetting.value(:site_name).presence || "Auto Enterprise"
  end

  def social_profile_url(platform, username)
    handle = username.to_s.strip.delete_prefix("@")
    return if handle.blank?

    "#{SOCIAL_PROFILE_URLS.fetch(platform)}#{ERB::Util.url_encode(handle)}"
  end

  def social_profile_handle(username)
    "@#{username.to_s.strip.delete_prefix("@")}"
  end

  def nav_link_classes(active: false)
    base_classes = "inline-flex items-center border-b-2 px-2 py-1 text-sm font-medium whitespace-nowrap transition"

    if active
      "#{base_classes} border-orange-500 text-orange-400"
    else
      "#{base_classes} border-transparent text-white/80 hover:border-orange-500/60 hover:text-orange-400"
    end
  end

  def nav_section_active?(*controller_names)
    controller_names.include?(controller_path)
  end
end
