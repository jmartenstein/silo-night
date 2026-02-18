$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'user'
require 'show'
require 'metadata_service'
require 'dotenv/load'

db_url = ENV['DATABASE_URL'] || (ENV['RACK_ENV'] == 'test' ? 'sqlite://data/test.db' : 'sqlite://data/silo_night.db')
Sequel.connect(db_url)

# Load show list from importer
source_show_list = JSON.parse(File.read("data/show_importer.json"))
service = MetadataService.new

source_show_list.each do |show_title|
  metadata = service.get_show_metadata(show_title)
  next unless metadata

  show = Show.find(name: metadata[:name])
  unless show
    Show.create(
      name:        metadata[:name],
      runtime:     metadata[:runtime],
      uri_encoded: URI.encode_www_form_component(metadata[:name].downcase)
    )
  end
end

def load_user(name)

  u = User.new
  u.load_from_file_by_username(name)

  if not User.find(name: name) then

    u.save

    j = JSON.parse(File.read("data/#{name}.json"))
    u = User.find(name: name)

    i = 0
    j["shows"].each do |s|
      show = Show.find(name: s)
      u.add_show(show)
      u.set_show_order(show, i)
      i += 1
    end

  end

end

load_user("test")
