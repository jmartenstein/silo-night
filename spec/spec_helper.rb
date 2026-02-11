require 'factory_bot'
require 'sequel'
require 'sequel/extensions/migration'

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    db = Sequel.connect('sqlite://data/silo_night.db')
    unless Sequel::Migrator.is_current?(db, 'db/migrations')
      puts "Database migrations are not up to date. Run 'rake db:migrate' first."
      exit 1
    end
    FactoryBot.find_definitions
  end
end
