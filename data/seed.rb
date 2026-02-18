$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'user'
require 'show'
require 'metadata_service'
require 'dotenv'
Dotenv.load(".env.#{ENV['RACK_ENV'] || 'development'}", ".env")

db_url = ENV['DATABASE_URL'] || (ENV['RACK_ENV'] == 'test' ? 'sqlite://data/test.db' : 'sqlite://data/silo_night.db')
Sequel.connect(db_url)

scenario = ENV['SEED_SCENARIO'] || 'smoke'
scenario_file = File.join(File.dirname(__FILE__), 'scenarios', "#{scenario}.rb")

if File.exist?(scenario_file)
  puts "Loading scenario: #{scenario}"
  load scenario_file
else
  puts "Scenario not found: #{scenario}"
  exit 1
end
