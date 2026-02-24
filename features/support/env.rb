require 'rack/test'
require 'dotenv'
Dotenv.load(".env.test", ".env")
require 'sequel'
require 'sequel/extensions/migration'
require 'database_cleaner/sequel'

ENV['RACK_ENV'] = 'test'
db_url = ENV['DATABASE_URL'] || 'sqlite://data/test.db'
db = Sequel.connect(db_url)
unless Sequel::Migrator.is_current?(db, 'db/migrations')
  puts "Database migrations are not up to date. Run 'RACK_ENV=test rake db:migrate' first."
  exit 1
end

DatabaseCleaner[:sequel].db = db
DatabaseCleaner[:sequel].strategy = :transaction

db.run("PRAGMA foreign_keys = OFF")
DatabaseCleaner[:sequel].clean_with(:truncation)
db.run("PRAGMA foreign_keys = ON")

# Load the smoke scenario to seed the database for tests
$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)
require 'user'
require 'show'
# Ensure we use the right DB connection in smoke.rb
DB = db unless defined?(DB)
load File.expand_path('../../data/scenarios/smoke.rb', __dir__)

Before do
  DatabaseCleaner[:sequel].start
end

After do
  DatabaseCleaner[:sequel].clean
end

require File.dirname(__FILE__) + '/../../silo_night'

$browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
