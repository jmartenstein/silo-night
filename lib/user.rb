require 'show'
require 'sequel'

Sequel.connect('sqlite://data/silo_night.db')

class User < Sequel::Model

  # make sure to include the show order when pulling the show association
  many_to_many :shows,
    select: [Sequel[:shows].*,
             Sequel[:shows_users][:show_order]],
    order: Sequel[:shows_users][:show_order]

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

  def load_from_json_string( text = "", load_shows = false )

    j = JSON.parse(text)

    # load the initial values
    @values[:name]     = j["name"]
    @values[:config]   = j["config"].to_json
    @values[:schedule] = j["schedule"].to_json

    # TODO: this is hacky, needs to be cleaned up
    if load_shows
      j["shows"].each { |s| add_show( Show.find(name: s) ) }
    end

    true

  end

  def load_from_file( filename = "" )
    text = File.read(filename)
    load_from_json_string(text)
    true
  end

  def load_shows_from_json( shows = "" )
    shows.each { |s| add_show( Show.find(name: s) ) }
  end

  def load_shows_from_file( filename = "")
    text = File.read(filename)
    load_show_from_json( text )
  end

  def load_from_file_by_username( name = "test" )
    load_from_file( "./data/#{name}.json" )
  end

  # TODO: Add code to make sure the show orders after this one are
  #       also updated
  def set_show_order( show="", order=0 )

    usershow_list = self.shows_dataset.all

    # remove the show from the list
    usershow_list.delete(show)

    i = 0
    while i < order do
      usershow_list[i].values[:show_order] = i
      i += 1
    end

    show.values[:show_order] = order
    usershow_list.insert(order, show)

    return usershow_list

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
        if not lookup_show.nil?
          runtime_sum += lookup_show.average_runtime
        end
      end
    end

    config = JSON.parse(@values[:config])
    config["time"].to_i - runtime_sum

  end

  def find_next_available_slot( show="" )

    lookup_show = self.shows_dataset.where( name: show ).first
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

    schedule

  end

end
