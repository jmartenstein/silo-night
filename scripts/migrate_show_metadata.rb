require_relative '../lib/database'
require_relative '../lib/show'
require_relative '../lib/show_metadata'

puts "Starting show metadata migration..."

DB.transaction do
  Show.each do |show|
    puts "Migrating metadata for: #{show.name}"
    
    payload = {
      runtime: show.runtime,
      poster_path: show.poster_path,
      wiki_page: show.wiki_page,
      page_title: show.page_title
    }

    # Use upsert logic to avoid duplicates if script is re-run
    ShowMetadata.upsert(
      provider_name: 'internal',
      external_id: show.uri_encoded || show.name.downcase.gsub(' ', '_'),
      payload: payload
    )
    
    # Link the newly created/updated metadata to the show
    metadata = ShowMetadata.find(provider_name: 'internal', external_id: show.uri_encoded || show.name.downcase.gsub(' ', '_'))
    metadata.update(show_id: show.id)
  end
end

puts "Migration complete!"
