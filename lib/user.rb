require 'show'
require 'database'

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
      else; nil
    end
  end

  def day_to_abbr( day="" )
    case day
      when "Sunday";    "s"
      when "Monday";    "m"
      when "Tuesday";   "t"
      when "Wednesday"; "w"
      when "Thursday";  "th"
      when "Friday";    "f"
      when "Saturday";  "sa"
    end
  end

  def day_enabled?( abbr="" )
    config = JSON.parse(self.config || "{}")
    days = config["days"] ? config["days"].split(",") : []
    days.include?(abbr)
  end

  def day_time( abbr="" )
    config = JSON.parse(self.config || "{}")
    # Current config has a single 'time' for all days.
    # New config might have 'time_m', 'time_t', etc.
    # Fallback to the global 'time' if the per-day time is not set.
    time = config["time_#{abbr}"] || config["time"] || "0"
    time.to_i
  end

  def total_day_time( abbr="" )
    return 0 unless day_enabled?(abbr)
    day_time(abbr)
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

  def is_show_in_schedule?( show="", schedule=nil )
    schedule ||= JSON.parse(@values[:schedule] || "{}")
    return false if schedule.nil?

    schedule.values.any? { |shows| shows.include?(show) }
  end

  def get_available_runtime_for_day( day="", schedule=nil )

    # TODO: add instance function to simplify this line
    schedule ||= JSON.parse(@values[:schedule] || "{}")
    schedule_day = schedule[day] || []

    # initialize an integer to track the runtime
    runtime_sum = 0

    # Optimization: Fetch all show runtimes for this day in one query if possible.
    # For now, let's at least ensure we use the shows relation if available, 
    # but schedule_day only has names.
    if not schedule_day.empty?
      lookup_shows = Show.where(name: schedule_day).all
      runtime_sum = lookup_shows.sum(&:average_runtime)
    end

    config = JSON.parse(@values[:config] || "{}")
    abbr = day_to_abbr(day)

    # if the day is not enabled, return 0
    days = config["days"] ? config["days"].split(",") : []
    return 0 unless days.include?(abbr)

    # lookup per-day time, then fallback to global time
    time_limit = config["time_#{abbr}"] || config["time"] || "0"
    time_limit.to_i - runtime_sum
  end

  def find_next_available_slot( show=nil, schedule=nil )

    return "" if show.nil?

    # Handle if show is a String (name) for backward compatibility
    lookup_show = if show.is_a?(String)
                    Show.find(name: show)
                  else
                    show
                  end

    return "" if lookup_show.nil?

    config = JSON.parse(self.config || "{}")
    next_available_day = ""

    days_str = config["days"] || ""
    days_str.split(",").each do |day|
      next if day.empty?
      full_day = config_day_lookup(day)
      next unless full_day
      avail = get_available_runtime_for_day(full_day, schedule)
      if lookup_show.average_runtime <= avail
        next_available_day = full_day
        break
      end
    end

    next_available_day

  end

  def generate_schedule()

    schedule = JSON.parse(@values[:schedule] || "{}")
    
    # Use the 'shows' association which respects 'show_order'
    self.shows.each do |show|

      if not is_show_in_schedule?(show.name, schedule)

        day = find_next_available_slot(show, schedule)
        if day && !day.empty?
          schedule[day] = [] unless schedule.key?(day)
          schedule[day].push(show.name)
        end

      end # if not ...
    end # shows.each

    self.schedule = schedule.to_json
    self.save
    schedule

  end

end
