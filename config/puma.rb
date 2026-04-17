threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

bind "unix:///var/run/puma/my_app.sock"

environment ENV.fetch("RAILS_ENV", "development")

pidfile ENV["PIDFILE"] if ENV["PIDFILE"]

preload_app!

plugin :tmp_restart