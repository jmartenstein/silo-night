require 'rack/test'
require 'sequel'
require 'sequel/extensions/migration'

db = Sequel.connect('sqlite://data/silo_night.db')
unless Sequel::Migrator.is_current?(db, 'db/migrations')
  puts "Database migrations are not up to date. Run 'rake db:migrate' first."
  exit 1
end

require File.dirname(__FILE__) + '/../../silo_night'

$browser = Rack::Test::Session.new(Rack::MockSession.new(Sinatra::Application))
