threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

if ENV["RAILS_ENV"] == "production"
  bind "unix:///var/run/puma/my_app.sock"
else
  port ENV.fetch("PORT", 3000)
end

environment ENV.fetch("RAILS_ENV", "development")

plugin :tmp_restart
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

pidfile ENV["PIDFILE"] if ENV["PIDFILE"]