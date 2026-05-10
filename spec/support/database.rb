# spec/support/database.rb
# Configuration for database management during test execution.
# This ensures that tests are run in a clean environment by truncating the database
# between tests and verifying migrations before the suite begins.

require 'sequel/extensions/migration'
require 'database_cleaner/sequel'

RSpec.configure do |config|
  # Run before the entire suite to verify schema state and setup cleaner strategies
  config.before(:suite) do
    unless Sequel::Migrator.is_current?(DB, 'db/migrations')
      puts "Database migrations are not up to date. Run 'RACK_ENV=test rake db:migrate' first."
      exit 1
    end
    
    DatabaseCleaner[:sequel].db = DB
    DatabaseCleaner[:sequel].strategy = :transaction

    # Reset database to a known clean state
    DB.run("PRAGMA foreign_keys = OFF")
    DatabaseCleaner[:sequel].clean_with(:truncation)
    DB.run("PRAGMA foreign_keys = ON")
  end

  # Wrap each test in a transaction to ensure database isolation
  config.around(:each) do |example|
    DatabaseCleaner[:sequel].cleaning do
      example.run
    end
  end
end
