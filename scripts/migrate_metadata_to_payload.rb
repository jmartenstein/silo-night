$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'database'
require 'show'
require 'show_metadata'

def migrate_metadata
  puts "Starting metadata migration..."
  
  Show.all.each do |show|
    # Skip if we already have metadata associated with this show
    next if show.metadata
    
    puts "Migrating metadata for: #{show.name}"
    
    # Create or update metadata record
    # Using 'local' as a default provider for migrated internal data
    metadata = ShowMetadata.find_or_create(
      provider_name: 'local',
      external_id: "show_#{show.id}"
    )
    
    # Assign the show_id foreign key
    metadata.update(show_id: show.id)
    
    # Populate the payload with existing columns
    new_payload = (metadata.payload || {}).merge({
      "runtime" => show.runtime,
      "poster_path" => show.poster_path
    })
    
    metadata.update(payload: new_payload)
  end
  
  puts "Metadata migration complete."
end

if __FILE__ == $0
  migrate_metadata
end
