# generate_schedule.rb

require 'json'
require 'logger'
require 'optparse'

def get_average_runtime(show_name)
  return 30
end

def get_config_minutes(time)
  return 55
end

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
  parser.on('-n', '--name NAME', 'Specify NAME to load config') do |n|
    options[:name] = n
  end
end.parse!

if options[:name].nil? then
  options[:name] = "test"
end

full_show_lookup = {}
File.open('../data/full_show_lookup.json') do |f|
  full_show_lookup = JSON.load(f)
end

filename = '../data/' + options[:name] + '.json'

user_data = {}
File.open(filename) do |f|
  user_data = JSON.load(f)
end

days = user_data["config"]["days"].split(",")
day_index = -1

#print days.length

total_minutes_per_day = get_config_minutes(user_data["config"]["time"])
temp_minutes = total_minutes_per_day

schedule = {}

user_data["shows"]. each do |show|
  break if day_index >= days.length - 1
  runtime = get_average_runtime(show)
  temp_minutes -= runtime
  if temp_minutes < runtime then
    temp_minutes = total_minutes_per_day
    day_index += 1
    schedule[days[day_index]] = []
  end
  print days[day_index] + " " + show + ": " + runtime.to_s + " " + temp_minutes.to_s + "\n"
  schedule[days[day_index]].append(show)
end

print schedule

#puts full_show_lookup[0]["name"]



