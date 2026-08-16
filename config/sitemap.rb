SitemapGenerator::Sitemap.default_host = "https://www.#{AppSetting.value('root_url')}"

puts "Sitemap host: #{SitemapGenerator::Sitemap.default_host}"

SitemapGenerator::Sitemap.create do
  add root_path, priority: 1.0, changefreq: "daily"
  add booking_path, priority: 0.8, changefreq: "weekly"
  add appointment_lookup_path, priority: 0.5, changefreq: "monthly"
end
