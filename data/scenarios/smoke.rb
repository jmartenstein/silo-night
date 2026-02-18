# Smoke test scenario
# Usage: load 'data/scenarios/smoke.rb'
require 'database_cleaner-sequel'
require 'json'
require 'uri'

puts "Seeding with smoke_test scenario..."

# We need to make sure we have a DB connection
unless defined?(DB)
  db_url = ENV['DATABASE_URL'] || (ENV['RACK_ENV'] == 'test' ? 'sqlite://data/test.db' : 'sqlite://data/silo_night.db')
  DB = Sequel.connect(db_url)
end

DB.run("PRAGMA foreign_keys = OFF"); DatabaseCleaner[:sequel].db = DB
DatabaseCleaner[:sequel].clean_with(:truncation); DB.run("PRAGMA foreign_keys = ON")

# 1. Create 3 diverse shows
shows_to_create = [
  { name: "Slow Horses", runtime: "45 minutes", uri_encoded: "slow+horses" },
  { name: "The Bear", runtime: "35 minutes", uri_encoded: "the+bear" },
  { name: "Only Murders in the Building", runtime: "35 minutes", uri_encoded: "only+murders+in+the+building" }
]

shows_to_create.each do |s|
  Show.create(s)
end

# 2. Create 1 test user with 2 shows in their schedule
# We'll use the data from test.json but override the schedule
user_data = JSON.parse(File.read("data/test.json"))
user_data["schedule"] = {
  "Tuesday": ["The Bear"],
  "Wednesday": ["Only Murders in the Building"]
}

user = User.new
user.name = user_data["name"]
user.config = user_data["config"].to_json
user.schedule = user_data["schedule"].to_json
user.save

# Add all 3 shows to the user's shows list (shows_users table)
shows_to_create.each_with_index do |s, i|
  show = Show.find(name: s[:name])
  user.add_show(show)
  # Use the DB to set the show_order since User class might have issues with it
  DB[:shows_users].where(user_id: user.id, show_id: show.id).update(show_order: i)
end

puts "Smoke scenario seeded: 3 shows, 1 user with 2 shows in schedule."
