# Empty scenario - clears all database tables
require 'database_cleaner-sequel'
require 'database'

puts "Seeding with empty scenario..."

DB.run("PRAGMA foreign_keys = OFF"); DatabaseCleaner[:sequel].db = DB
DatabaseCleaner[:sequel].clean_with(:truncation); DB.run("PRAGMA foreign_keys = ON")

puts "Database tables truncated."
