require 'show'
require 'sequel'

Sequel.connect('sqlite://data/silo_night.db')

class User < Sequel::Model

  many_to_many :shows

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

  def load_from_file( filename = "" )

    text = File.read(filename)
    j = JSON.parse(text)

    # load the initial values
    @values[:name]     = j["name"]
    @values[:config]   = j["config"].to_json
    @values[:schedule] = j["schedule"].to_json

    true

  end

  def load_shows_from_file( filename = "")
    text = File.read(filename)
    j = JSON.parse(text)

    if j["shows"] then
      j["shows"].each { |s| add_show( Show.find(name: s) ) }
    end
    true
  end

  def load_from_file_by_username( name = "test" )
    load_from_file( "./data/#{name}.json" )
  end

  def is_show_in_schedule?( show="" )
    schedule = JSON.parse(@values[:schedule])
    if not schedule.nil?
      schedule.keys.each { |day| return true if schedule[day].include?( show ) }
    end
    false
  end

  def get_available_runtime_for_day( day="" )

    # TODO: add instance function to simplify this line
    schedule = JSON.parse(@values[:schedule]) || {}
    schedule_day = schedule[day] || nil

    # initialize an integer to track the runtime
    runtime_sum = 0

    if not schedule_day.nil?
      schedule_day.each do |show|
        lookup_show = shows_dataset.where( name: show ).first
        runtime_sum += lookup_show.average_runtime
      end
    end

    config = JSON.parse(@values[:config])
    config["time"].to_i - runtime_sum

  end

  def find_next_available_slot( show="" )

    lookup_show = shows_dataset.where( name: show ).first
    config = JSON.parse(@values[:config])
    next_available_day = ""

    config["days"].split(",").each do |day|
      avail = get_available_runtime_for_day(config_day_lookup(day))
      if lookup_show.average_runtime <= avail
        next_available_day = config_day_lookup(day)
        break
      end
    end

    next_available_day

  end

  def generate_schedule()

    schedule = JSON.parse(@values[:schedule]) || {}
    shows_dataset.each do |show|

      if not is_show_in_schedule?(show.name)

        day = find_next_available_slot(show.name)
        schedule[day] = [] unless schedule.key?(day)

        schedule[day].push(show.name)
        @values[:schedule] = schedule.to_json.to_s

      end # if not ...
    end # shows_dataset.each

  end

end
