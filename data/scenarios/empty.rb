# Empty scenario - clears all database tables
require 'database_cleaner-sequel'

puts "Seeding with empty scenario..."

# We need to make sure we have a DB connection
# If not already connected, connect to the default or environment DB
unless defined?(DB)
  db_url = ENV['DATABASE_URL'] || (ENV['RACK_ENV'] == 'test' ? 'sqlite://data/test.db' : 'sqlite://data/silo_night.db')
  DB = Sequel.connect(db_url)
end

DB.run("PRAGMA foreign_keys = OFF"); DatabaseCleaner[:sequel].db = DB
DatabaseCleaner[:sequel].clean_with(:truncation); DB.run("PRAGMA foreign_keys = ON")

puts "Database tables truncated."
