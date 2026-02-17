# expand_shows.rb

require 'json'
require 'logger'
require 'optparse'
require 'uri'
require 'dotenv/load'
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'metadata_service'

@err_logger = Logger.new(STDERR)
@out_logger = Logger.new(STDOUT)

options = {}
parser = OptionParser.new do |parser|
  parser.banner = "Usage: expand_shows.rb [options]"
  parser.on('-v', '--[no-]verbose', 'Verbose mode') do |v|
    options[:verbose] = v
  end
  parser.on('-d', '--[no-]debug', 'Debug mode') do |d|
    options[:debug] = d
  end
  parser.on('-h', '--help', 'Print this help') do |v|
    puts parser
    exit
  end
end.parse!

if options[:verbose] || options[:debug]
  @err_logger.level = Logger::INFO
else
  @err_logger.level = Logger::ERROR
end

service = MetadataService.new

source_show_list = []
begin
  File.open('./data/show_importer.json') do |f|
    source_show_list = JSON.load(f)
  end
rescue => e
  @err_logger.error("Failed to load show_importer.json: #{e.message}")
  exit 1
end

destination_list = []

source_show_list.each do |show_title|
  @err_logger.info("Fetching metadata for: #{show_title}")
  
  metadata = service.get_show_metadata(show_title)
  
  if metadata
    show_hash = {
      'name' => metadata[:name],
      'runtime' => metadata[:runtime],
      'uri_encoded' => URI.encode_www_form_component(metadata[:name].downcase),
      'wiki_page' => nil, # No longer scraping Wikipedia
      'page_title' => nil,
      'tmdb_id' => metadata[:external_ids][:tmdb_id],
      'tvmaze_id' => metadata[:external_ids][:tvmaze_id]
    }
    
    destination_list << show_hash
    @err_logger.info("Successfully fetched metadata for: #{metadata[:name]}")
  else
    @err_logger.error("Could not find metadata for: #{show_title}")
  end
end

begin
  File.open('./data/full_show_lookup.json', 'w') do |f|
    f.write(JSON.pretty_generate(destination_list))
  end
  @out_logger.info("Successfully updated data/full_show_lookup.json with #{destination_list.length} shows.")
rescue => e
  @err_logger.error("Failed to write full_show_lookup.json: #{e.message}")
end
