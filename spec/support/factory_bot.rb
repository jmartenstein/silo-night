# spec/support/factory_bot.rb
# Configuration for FactoryBot test data generation.
# This ensures that factories are properly defined and provides helper methods
# directly within RSpec test examples.

require 'factory_bot'

# Set default persistence behavior for generated objects
FactoryBot.define do
  to_create { |instance| instance.save }
end

RSpec.configure do |config|
  # Include FactoryBot methods (create, build, etc.) globally
  config.include FactoryBot::Syntax::Methods
  
  # Register factory definitions once before the test suite begins
  config.before(:suite) do
    FactoryBot.find_definitions
  end
end
