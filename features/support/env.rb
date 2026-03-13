ENV['RACK_ENV'] = 'test'
require 'rack/test'
$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)
require 'database'
require 'sequel/extensions/migration'
require 'database_cleaner/sequel'

unless Sequel::Migrator.is_current?(DB, 'db/migrations')
  puts "Database migrations are not up to date. Run 'RACK_ENV=test rake db:migrate' first."
  exit 1
end

DatabaseCleaner[:sequel].db = DB
DatabaseCleaner[:sequel].strategy = :transaction

DB.run("PRAGMA foreign_keys = OFF")
DatabaseCleaner[:sequel].clean_with(:truncation)
DB.run("PRAGMA foreign_keys = ON")

Before do
  DatabaseCleaner[:sequel].start
end

After do
  DatabaseCleaner[:sequel].clean
end

require File.dirname(__FILE__) + '/../../silo_night'

$browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
