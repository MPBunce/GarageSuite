environment ENV.fetch("RAILS_ENV", "development")
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

environment ENV.fetch("RAILS_ENV", "development")

if ENV.fetch("RAILS_ENV", "development") == "production"
	bind "unix:///var/run/puma/my_app.sock"
else
	port ENV.fetch("PORT", 3000)
end

pidfile ENV["PIDFILE"] if ENV["PIDFILE"]

preload_app!

plugin :tmp_restart

plugin :tmp_restart