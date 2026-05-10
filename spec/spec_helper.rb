# spec/spec_helper.rb
# This file is the primary entry point for the RSpec test suite.
# It handles global load paths, environment initialization, and auto-loading
# of support configurations from the spec/support/ directory.

require 'cgi'

# Fallback for older CGI/VCR compatibility issues to support consistent parameter parsing.
unless CGI.respond_to?(:parse)
  def CGI.parse(query)
    params = {}
    query.split(/[&;]/).each do |pairs|
      key, value = pairs.split('=', 2).map { |v| CGI.unescape(v) }
      if params.has_key?(key)
        params[key] << value
      else
        params[key] = [value]
      end
    end
    params
  end
end

# Set test environment
ENV['RACK_ENV'] = 'test'
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift File.expand_path('..', __dir__)

# Load base testing dependencies
require 'database'
require 'rack/test'
require 'dotenv'
require 'webmock/rspec'

# Load test-specific environment configuration
Dotenv.load('.env.test')
require_relative '../silo_night'

# Dynamically load all support configuration files (e.g., database, factory_bot)
Dir[File.join(__dir__, 'support/**/*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  # Enable rack-test methods for integration/request specs
  config.include Rack::Test::Methods

  # Automatically tag specs based on file directory for architectural testing
  config.define_derived_metadata(file_path: %r{spec/(presenters|lib)/}) do |metadata|
    metadata[:type] = :unit
  end

  config.define_derived_metadata(file_path: %r{spec/(integration|adapters|requests)/}) do |metadata|
    metadata[:type] = :integration
  end

  # Define the Sinatra application under test
  def app
    Sinatra::Application
  end
end
