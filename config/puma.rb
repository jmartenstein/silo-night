# Puma configuration for silo-night
environment ENV.fetch("RACK_ENV") { "development" }

# Single source of truth for host and port binding.
# - Development: Bind only to localhost (127.0.0.1) for security.
# - Test/Production: Bind to all interfaces (0.0.0.0) for network access.
port = ENV.fetch("PORT") { 9292 }
if ENV.fetch("RACK_ENV") { "development" } == "development"
  bind "tcp://127.0.0.1:#{port}"
else
  bind "tcp://0.0.0.0:#{port}"
end
