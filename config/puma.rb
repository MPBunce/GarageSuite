threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

# Elastic Beanstalk provides PORT
port ENV.fetch("PORT", 8080)

environment ENV.fetch("RAILS_ENV", "development")

# Restart support
plugin :tmp_restart

# PID file (optional but fine)
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]

# Optional: preload for performance (safe for most apps)
preload_app!

# Allow puma to be restarted by `bin/rails restart`
plugin :tmp_restart