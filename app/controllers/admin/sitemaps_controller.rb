class Admin::SitemapsController < Admin::BaseController
  def rebuild
    SitemapRebuildJob.perform_now
    redirect_to admin_settings_path, notice: "Sitemap rebuilt."
  end
end