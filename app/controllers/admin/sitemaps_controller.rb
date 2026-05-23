class Admin::SitemapsController < Admin::BaseController
  def rebuild
    SitemapRebuildJob.perform_later
    redirect_to admin_settings_path, notice: "Sitemap rebuild queued."
  end
end