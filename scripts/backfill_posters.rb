# scripts/backfill_posters.rb
# Backfill poster_path for existing shows using MetadataService

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'database'
require 'show'
require 'metadata_service'

puts "Starting poster backfill..."

service = MetadataService.new
shows = Show.where(Sequel.or(poster_path: nil, poster_path: "")).all

puts "Found #{shows.count} shows to backfill."

shows.each do |show|
  puts "Fetching metadata for: #{show.name}"
  metadata = service.get_show_metadata(show.name)
  
  if metadata && metadata[:poster_path]
    show.update(poster_path: metadata[:poster_path])
    puts "  Updated: #{metadata[:poster_path]}"
  else
    puts "  No poster found."
  end
  
  # Be nice to the APIs
  sleep(0.1)
end

puts "Backfill complete."
