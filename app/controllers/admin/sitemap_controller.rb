# app/controllers/admin/sitemaps_controller.rb
class Admin::SitemapsController < ApplicationController
  before_action :require_admin

  def rebuild
    SitemapRebuildJob.perform_later
    render json: { status: 'queued' }
  end
end