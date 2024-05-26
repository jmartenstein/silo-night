# silo_night.rb

require 'sinatra'
require 'sinatra/contrib'
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

post '/schedule' do
  slim :schedule
end

namespace '/api/v0.1' do

  put '/user/:name/schedule' do
    content_type :json
    ['The Amazing Race'].to_json
  end

  get '/user/:name/shows' do

    user_id = db[:users].where(name: params["name"]).first[:id]
    usershows = db[:usershows].join(:shows, id: :show_id)

    show_name_list = usershows.select(:name).where(user_id: user_id)
    show_names = show_name_list.all.map{ |i| i[:name] }

    content_type :json
    show_names.to_json

  end

end

get '/user/:name/shows' do

  # lookup user_id based on name
  user_id = db[:users].where(name: params["name"])

  puts user_id

  # get the list of shows associated with the username
  shows = db[:shows].select(:name).where(id: user_id)

  slim :user_shows, :locals => { :shows => shows }

end
