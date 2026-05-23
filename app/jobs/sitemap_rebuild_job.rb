# app/jobs/sitemap_rebuild_job.rb
class SitemapRebuildJob < ApplicationJob
  queue_as :default

  def perform
    `bundle exec rake sitemap:refresh`
  end
end