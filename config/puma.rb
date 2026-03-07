# Puma configuration for silo-night
port        ENV.fetch("PORT") { 9292 }
environment ENV.fetch("RACK_ENV") { "development" }

# In development mode, bind only to localhost for security.
# In test and production modes, bind to all interfaces to allow external access.
if ENV.fetch("RACK_ENV") { "development" } == "development"
  bind "tcp://127.0.0.1:#{ENV.fetch("PORT") { 9292 }}"
else
  bind "tcp://0.0.0.0:#{ENV.fetch("PORT") { 9292 }}"
end
