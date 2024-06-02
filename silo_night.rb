# silo_night.rb

require 'sinatra'
require 'sinatra/contrib'

require 'sequel'
require 'user'

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
    u = User.find(name: params["name"])
    sched = u.generate_schedule
    sched.to_json
  end

  get '/user/:name/schedule' do
    content_type :json
    u = User.find(name: params["name"])
    sched = u.generate_schedule
    sched.to_json
  end

  post '/user/:name/show' do
    content_type :json

    u = User.find(name: params["name"])
    s = Show.find(name: params["show"])

    if s.nil? then
      "couldn't find show #{params["show"]}"
    else
      u.add_show(s)
    end

    u.shows.map { |s| s.name }.to_json

  end

  delete '/user/:name/show/:show' do

    u = User.find(name: params["name"])
    s = Show.find(uri_encoded: params["show"])

    if s.nil? then
      "couldn't find show #{params["show"]}"
    else
      u.remove_show(s)
    end

    u.shows.map { |s| s.name }.to_json

  end

  get '/user/:name/shows' do
    content_type :json
    u = User.find(name: params["name"])
    u.shows.map { |s| s.name }.to_json
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
