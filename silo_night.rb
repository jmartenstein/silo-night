# silo_night.rb

require 'sinatra'
require 'sequel'

# set slim templates to custom diectory
set :views, File.expand_path(File.join(__FILE__, '../template'))

# load the databae
db = Sequel.connect('sqlite://data/silo_night.db')

get '/' do
  slim :index
end

get '/schedule' do
  slim :schedule
end

get '/user/:name/shows' do

  # lookup user_id based on name
  user_id = db[:users].where(name: params["name"])

  puts user_id

  # get the list of shows associated with the username
  shows = db[:shows].select(:name).where(id: user_id)

  slim :user_shows, :locals => { :shows => shows }

end
