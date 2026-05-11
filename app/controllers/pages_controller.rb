class PagesController < ApplicationController
  def home
    @services = Service.active.order(:name)
    if user_signed_in?
      if current_user.admin?
        redirect_to admin_dashboard_path
      else
        redirect_to customer_dashboard_path
      end
    end
  end

  def robots
    render plain: "User-agent: *\nDisallow: /admin\nDisallow: /dashboard\nSitemap: https://www.#{AppSetting.value('root_url')}/sitemap.xml", content_type: 'text/plain'
  end
end