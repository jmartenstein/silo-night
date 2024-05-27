require 'user'
require 'show'

Sequel.connect('sqlite://data/silo_night.db')

l = Shows.new()
l.load_from_file("data/full_show_lookup.json")
l.each do |show| 
  show.save
end

u1 = User.new
name = "justin"
u1.load_from_file_by_username(name)
u1.save

u2 = User.new
name = "test"
u2.load_from_file_by_username("test")
u2.save
