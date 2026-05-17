# Smoke test scenario
# Usage: load 'data/scenarios/smoke.rb'
require 'database_cleaner-sequel'
require 'json'
require 'uri'
require 'database'
require 'show'
require 'user'
require 'services/show_factory'
require 'metadata_service'
require 'vcr'
require 'cgi'

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.hook_into :webmock
end

puts "Seeding with smoke_test scenario..."

DB.run("PRAGMA foreign_keys = OFF"); DatabaseCleaner[:sequel].db = DB
DatabaseCleaner[:sequel].clean_with(:truncation); DB.run("PRAGMA foreign_keys = ON")

# 1. Create shows needed for the Cucumber tests and general smoke testing
shows_to_create = [
  "Slow Horses",
  "The Bear",
  "Only Murders in the Building",
  "The Equalizer",
  "Suits",
  "The Afterparty",
  "His Dark Materials",
  "The Amazing Race",
  "Platonic"
]

VCR.use_cassette('smoke_scenario_seeds') do
  shows_to_create.each do |name|
    Services::ShowFactory.create_with_metadata(name)
  end
end

# 2. Create users expected by Cucumber tests
users_to_create = [
  {
    name: "steph",
    config: { "days" => "t,w,th,f", "time" => "85m" },
    schedule: { "Thursday" => ["The Afterparty"] },
    shows: ["The Equalizer", "Suits", "The Afterparty"]
  },
  {
    name: "justin",
    config: { "days" => "t,w,th,f", "time" => "85m" },
    schedule: {},
    shows: ["His Dark Materials"]
  },
  {
    name: "test",
    config: { "days" => "t,w,th,f", "time" => "85m" },
    schedule: {},
    shows: []
  }
]

users_to_create.each do |u_data|
  user = User.new
  user.name = u_data[:name]
  user.config = u_data[:config].to_json
  user.schedule = u_data[:schedule].to_json
  user.save

  u_data[:shows].each_with_index do |show_name, i|
    show = Show.find(name: show_name)
    user.add_show(show)
    # Set show_order in the join table
    DB[:shows_users].where(user_id: user.id, show_id: show.id).update(show_order: i)
  end
end

puts "Smoke scenario seeded: #{Show.count} shows, #{User.count} users."
