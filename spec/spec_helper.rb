ENV['RACK_ENV'] = 'test'
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift File.expand_path('..', __dir__)

require 'factory_bot'
require 'sequel'
require 'sequel/extensions/migration'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    db_url = ENV['DATABASE_URL'] || 'sqlite://data/test.db'
    db = Sequel.connect(db_url)
    unless Sequel::Migrator.is_current?(db, 'db/migrations')
      puts "Database migrations are not up to date. Run 'RACK_ENV=test rake db:migrate' first."
      exit 1
    end
    FactoryBot.find_definitions
  end
end
