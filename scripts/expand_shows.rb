# expand_shows.rb

require 'faraday'
require 'json'
require 'logger'
require 'optparse'
require 'uri'

def get_page_info(conn, show_name)

  # run the search
  @err_logger.info("Searching for \"#{show_name}\" wiki page")
  search_resp = conn.get() do |req|
    req.params['action'] = 'opensearch'
    req.params['search'] = show_name
    req.params['namespace'] = 0
    req.params['format'] = 'json'
  end

  # get the wiki page title out of the json object
  address = search_resp.body[3][0].to_s
  page_name = search_resp.body[1][0].to_s

  if page_name != "" then
    @err_logger.info("Found wiki page: #{page_name}")
  else
    @err_logger.error("Can't find wiki title for: " + show_name)
  end

  return page_name, address

end

def get_runtime(conn, page)

  # parse the page
  parse_resp = conn.get() do |req|
    req.params['action'] = 'parse'
    req.params['page'] = page
    req.params['prop'] = 'wikitext'
    req.params['section'] = 0
    req.params['format'] = 'json'
  end

  wiki_text = ""
  runtime = ""

  begin
    wiki_text = parse_resp.body['parse']['wikitext']['*']
  rescue NoMethodError
    @err_logger.error("No text found for: " + page)
  else
    #@err_logger.info("Found wiki text for: " + show_name)
    begin
      runtime_match = /^.*runtime.+= (.+ minutes).*$/.match(wiki_text)
    rescue NoMethodError
      @err_logger.error("Match function failed for: " + wiki_text)
    else
      if runtime_match then 
        runtime = runtime_match[1] 
      else
        @err_logger.error("Match for 'runtime' failed: " + page)
      end
    end
  end

  return runtime

end

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

if options[:verbose] then
  @err_logger.level = Logger::INFO
else
  @err_logger.level = Logger::ERROR
end

connection = Faraday.new(
  url: "https://en.wikipedia.org/w/api.php",
  headers: {'Content-Type' => 'application/json'}
) do |c|
  c.request :json
  c.response :json
end

source_show_list = {}

File.open('./data/show_importer.json') do |f|
  source_show_list = JSON.load(f)
end

destination_list = []

source_show_list.each { |show| 

  show_hash = {}
  title, address = get_page_info(connection, show)
  if title != "" then
    runtime = get_runtime(connection, title)
  end

  if runtime == "" then
    title, address = get_page_info(connection, show + " tv series")
    runtime = get_runtime(connection, title)
  end

  p = URI::Parser.new
  show_match = /([^\(]+).*/.match(show)

  show_name = show_match[1].strip

  show_hash['name'] = show_name
  show_hash['wiki_page'] = title
  show_hash['page_title'] = address
  show_hash['runtime'] = runtime
  show_hash['uri_encoded'] = p.escape(show_name.downcase)

  if runtime != "" then
    destination_list += [show_hash]
  end

}

File.open('./data/full_show_lookup.json', 'w') do |f|
  f.write(JSON.pretty_generate(destination_list)) 
end
