ENV['RACK_ENV'] = 'test'
require 'dotenv'
Dotenv.load(".env.test", ".env")
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift File.expand_path('..', __dir__)

require 'factory_bot'
require 'sequel'
require 'sequel/extensions/migration'
require 'webmock/rspec'
require 'vcr'
require 'database_cleaner/sequel'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.filter_sensitive_data('<TMDB_API_KEY>') { ENV['TMDB_API_KEY'] }
  config.filter_sensitive_data('<TVMAZE_API_KEY>') { ENV['TVMAZE_API_KEY'] }
  config.configure_rspec_metadata!
end

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
    DatabaseCleaner[:sequel].db = db
    DatabaseCleaner[:sequel].strategy = :transaction

    db.run("PRAGMA foreign_keys = OFF")
    DatabaseCleaner[:sequel].clean_with(:truncation)
    db.run("PRAGMA foreign_keys = ON")
  end

  config.around(:each) do |example|
    DatabaseCleaner[:sequel].cleaning do
      example.run
    end
  end
end
