# expand_shows.rb

require 'faraday'
require 'json'
require 'logger'
require 'optparse'

def get_runtime(conn, show_name)
 
  # run the search
  search_resp = conn.get() do |req|
    req.params['action'] = 'opensearch'
    req.params['search'] = show_name + ' tv series'
    req.params['namespace'] = 0
    req.params['format'] = 'json'
  end

  # get the wiki page title out of the json object
  begin
    wiki_title1 = search_resp.body[1][0].to_s
  rescue NoMethodError
    @err_logger.error("ERROR: Can't find wiki title for: " + show_name)
    wiki_title1 = ""
  end

  # parse the page
  parse_resp = conn.get() do |req|
    req.params['action'] = 'parse'
    req.params['page'] = wiki_title1
    req.params['prop'] = 'wikitext'
    req.params['section'] = 0
    req.params['format'] = 'json'
  end

  wiki_text = ""
  runtime = ""

  begin
    wiki_text = parse_resp.body['parse']['wikitext']['*']
  rescue NoMethodError
    @err_logger.error("Can't find wiki text for: " + show_name)
  else
    begin
      runtime_match = /^.*runtime.+= (.+ minutes).*$/.match(wiki_text)
    rescue NoMethodError
      @err_logger.error("ERROR: No runtime match for: " + show_name)
    else
      if runtime_match then 
        runtime = runtime_match[1] 
      else
        @err_logger.error("ERROR: No match for: " + show_name)
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
  parser.on('-d', '--[no-]debug', 'Debug mode') do |v|
    options[:debug] = v
  end
  parser.on('-h', '--help', 'Print this help') do |v|
    puts parser
    exit
  end
end.parse!

connection = Faraday.new(
  url: "https://en.wikipedia.org/w/api.php",
  headers: {'Content-Type' => 'application/json'}
) do |c|
  c.request :json
  c.response :json
  #c.response :logger
end

source_show_list = {}

File.open('../data/show_importer.json') do |f|
  source_show_list = JSON.load(f)
end

destination_list = []

source_show_list.each { |show| 
  show_hash = {}
  runtime = get_runtime(connection, show)
  if runtime != "" then
    show_hash['name'] = show
    show_hash['runtime'] = runtime
  end
  destination_list += [show_hash]
}

File.open('../data/full_show_lookup.json', 'w') do |f|
  f.write(JSON.pretty_generate(destination_list)) 
end
