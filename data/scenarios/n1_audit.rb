# N+1 Audit scenario
# Usage: load 'data/scenarios/n1_audit.rb'
require 'database_cleaner-sequel'
require 'json'
require 'uri'

puts "Seeding with n1_audit scenario..."

# We need to make sure we have a DB connection
unless defined?(DB)
  db_url = ENV['DATABASE_URL'] || (ENV['RACK_ENV'] == 'test' ? 'sqlite://data/test.db' : 'sqlite://data/silo_night.db')
  DB = Sequel.connect(db_url)
end

# Disable foreign keys for truncation in SQLite
DB.run("PRAGMA foreign_keys = OFF")
DatabaseCleaner[:sequel].db = DB
DatabaseCleaner[:sequel].clean_with(:truncation)
DB.run("PRAGMA foreign_keys = ON")

# 1. Create 100+ shows
base_shows = JSON.parse(File.read("data/full_show_lookup.json")) rescue []
(1..100).each do |i|
  show_data = if i <= base_shows.length
                base_shows[i-1]
              else
                {
                  "name" => "Synthetic Show #{i}",
                  "runtime" => "#{30 + (i % 30)} minutes",
                  "uri_encoded" => "synthetic-show-#{i}",
                  "wiki_page" => nil,
                  "page_title" => nil,
                  "tmdb_id" => nil,
                  "tvmaze_id" => 1000 + i
                }
              end
  
  Show.create(
    name:        show_data["name"],
    runtime:     show_data["runtime"],
    uri_encoded: show_data["uri_encoded"] || URI.encode_www_form_component(show_data["name"].downcase)
  )
end

all_shows = Show.all

# 2. Create 10+ users with complex schedules
(1..10).each do |u_id|
  user_name = "user_#{u_id}"
  
  user = User.new
  user.name = user_name
  user.config = {
    "days" => "m,t,w,th,f,s,sa",
    "time" => "#{120 + (u_id * 10)}m"
  }.to_json
  
  # Pick 15 random shows for this user
  user_shows = all_shows.sample(15)
  
  # Generate a complex schedule
  schedule = {}
  days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
  
  user_shows.each_with_index do |show, idx|
    day = days[idx % days.length]
    schedule[day] ||= []
    schedule[day].push(show.name)
  end
  
  user.schedule = schedule.to_json
  user.save
  
  # Add shows to the shows_users table
  user_shows.each_with_index do |show, idx|
    user.add_show(show)
    DB[:shows_users].where(user_id: user.id, show_id: show.id).update(show_order: idx)
  end
end

puts "N+1 Audit scenario seeded: 100 shows, 10 users with complex schedules."
