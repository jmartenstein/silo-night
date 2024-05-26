require 'show'
require 'sequel'

class User

  attr_accessor :config
  attr_accessor :shows
  attr_accessor :schedule

  def initialize( u={"config"=>{},"shows"=>[],"schedule"=>{}} )
    @config   = u["config"] || {}
    @schedule = u["schedule"] || {}
    @shows    = u["shows"] | []
  end

  def config_day_lookup( day="" )
    case day
      when "s";  "Sunday"
      when "m";  "Monday"
      when "t";  "Tuesday"
      when "w";  "Wednesday"
      when "th"; "Thursday"
      when "f";  "Friday"
      when "sa"; "Saturday"
    end
  end

  def add_show( show="" )
    @shows.push( show )
  end

  def delete_show( show="" )
    @shows.delete( show )
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

    temp = Shows.new()

    # build a temporary list of shows from the lookup
    @shows.each do |show| 
      lookup_show = lookup.find { |i| i.name == show }
      temp.list.append lookup_show if not lookup_show.nil?
    end
    @shows = temp

    true

  end

  def is_show_in_schedule?( show="" )
    @schedule.keys.each { |day| true if @schedule[day].include?( show ) }
    false
  end

  def get_available_runtime_for_day( day="" )

    # check to see if we need to add runtime information to the shows
    expand_shows() if (@shows.count == 0) or (@shows[0].class == String)

    day_schedule = @schedule[day]
    runtime_sum = 0

    if not day_schedule.nil?
      day_schedule.each do |show|
        lookup_show = @shows.find { |i| i.name == show }
        runtime_sum += lookup_show.average_runtime
      end
    end

    @config["time"].to_i - runtime_sum

  end

  def find_next_available_slot( show="" )

    # check to see if we need to add runtime information to the shows
    expand_shows() if (@shows.count == 0) or (@shows[0].class == String)

    lookup_show = @shows.find { |i| i.name == show }
    next_available_day = ""

    @config["days"].each do |day|
      avail = get_available_runtime_for_day(config_day_lookup(day))
      if lookup_show.average_runtime <= avail
        next_available_day = config_day_lookup(day)
        break
      end
    end

    next_available_day

  end

  def generate_schedule()
    @shows.each do |show|

      if not is_show_in_schedule?(show)
        day = find_next_available_slot(show)
        @schedule[day] = [] unless @schedule.key?(day)
        @schedule[day].push(show)
      end

    end
  end

end
