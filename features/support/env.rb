ENV['RACK_ENV'] = 'test'
require 'rack/test'
require 'factory_bot'
FactoryBot.define do
  to_create { |instance| instance.save }
end
FactoryBot.find_definitions
$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)
require 'database'
require 'sequel/extensions/migration'
require 'database_cleaner/sequel'
require 'vcr'
require 'cgi'

# Configure VCR for Cucumber
VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
  config.filter_sensitive_data('<TMDB_API_KEY>') { ENV['TMDB_API_KEY'] }
  config.filter_sensitive_data('<TVMAZE_API_KEY>') { ENV['TVMAZE_API_KEY'] }
end

# Manage cassettes for tagged scenarios
Around('@vcr') do |scenario, block|
  name = scenario.name.gsub(/[^\w-]/, '_').downcase
  VCR.use_cassette("cucumber/#{name}") do
    block.call
  end
end

unless Sequel::Migrator.is_current?(DB, 'db/migrations')
  puts "Database migrations are not up to date. Run 'RACK_ENV=test rake db:migrate' first."
  exit 1
end

DatabaseCleaner[:sequel].db = DB
DatabaseCleaner[:sequel].strategy = :transaction

DB.run("PRAGMA foreign_keys = OFF")
DatabaseCleaner[:sequel].clean_with(:truncation)
DB.run("PRAGMA foreign_keys = ON")

# Seed smoke data once at suite startup, outside per-scenario transactions
load File.join(File.dirname(__FILE__), '../../data/scenarios/smoke.rb')

Before do
  DatabaseCleaner[:sequel].start
end

After do
  DatabaseCleaner[:sequel].clean
end

require File.dirname(__FILE__) + '/../../silo_night'

$browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))

World(FactoryBot::Syntax::Methods)
