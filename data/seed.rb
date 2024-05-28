require 'user'
require 'show'

Sequel.connect('sqlite://data/silo_night.db')

l = Shows.new()
l.load_from_file("data/full_show_lookup.json")
l.each do |show| 
  show.save unless Show.find(name: show.name)
end

def load_user(name)

  u = User.new
  u.load_from_file_by_username(name)

  if not User.find(name: name) then

    u.save

    j = JSON.parse(File.read("data/#{name}.json"))
    u = User.find(name: name)
    j["shows"].each { |s| u.add_show( Show.find(name: s)) }

  end

end

load_user("justin")
load_user("test")
load_user("steph")
