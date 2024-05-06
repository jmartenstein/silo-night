require 'show'
require 'sequel'

class User

  attr_accessor :config
  attr_accessor :shows
  attr_accessor :schedule

  def initialize( u={"config"=>{},"shows"=>[],"schedule"=>{}} )
    @config   = u["config"]
    @schedule = u["schedule"]
    @shows    = u["shows"]
  end

  def load_from_file( filename = "" )

    text = File.read(filename)
    j = JSON.parse(text)

    # TODO: can these be mapped to a single line?
    @config   = j["config"]
    @shows    = j["shows"]
    @schedule = j["schedule"]

    true

  end

  def load_from_file_by_username( name = "test" )
    load_from_file( "./data/#{name}.json" )
  end

  def load_from_sql_by_username( name = "" )

    db = Sequel.connect('sqlite://data/silo_night.db')
    user = db[:users].where(name: name).first
    usershows = db[:usershows].join(:shows, id: :show_id)

    show_name_list = usershows.select(:name).where(user_id: user[:id])
    @shows = show_name_list.all.map{ |i| i[:name] }

    true

  end

  def save_to_sql()
  end

  def expand_shows()

    # create a lookup from the test data
    lookup = Shows.new()
    lookup.load_from_file("spec/support/shows.json")
    temp = []

    # build a temporary list of shows from the lookup
    @shows.each do |show| 
      temp.append( lookup.find { |k,v| v = show } )
    end
    @shows = temp

    return true

  end

  def generate_schedule()
    @schedule = { "monday" => ["foo"], "tuesday" => ["bar"] }
  end

end
