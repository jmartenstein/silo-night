require 'rack/test'
require 'sequel'
require 'sequel/extensions/migration'

ENV['RACK_ENV'] = 'test'
db_url = ENV['DATABASE_URL'] || 'sqlite://data/test.db'
db = Sequel.connect(db_url)
unless Sequel::Migrator.is_current?(db, 'db/migrations')
  puts "Database migrations are not up to date. Run 'RACK_ENV=test rake db:migrate' first."
  exit 1
end

require File.dirname(__FILE__) + '/../../silo_night'

$browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
