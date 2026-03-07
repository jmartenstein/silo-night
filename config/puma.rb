# Puma configuration for silo-night
port        ENV.fetch("PORT") { 9292 }
environment ENV.fetch("RACK_ENV") { "development" }

# Allow for other hosts to access the service by binding to all interfaces.
# The 'port' method in Puma is a shortcut for 'bind "tcp://0.0.0.0:#{port}"'.
