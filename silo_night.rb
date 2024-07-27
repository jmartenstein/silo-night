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
  @users = User.map { |x| x[:name] }
  slim :index
end

get '/user/:name/schedule' do
  @schedule = JSON.parse(User.find(name: params["name"]).schedule)
  slim :schedule
end

get '/user/:name/schedule/edit' do
  @schedule = User.find(name: params["name"]).schedule
  slim :schedule_edit
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

  get '/user/:name/tonight' do

    content_type :json
    today = Date.today.strftime('%A')

    u = User.find(name: params["name"])
    j = JSON.parse(u.schedule)

    j[today].to_json

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
  u = User.find(name: params["name"])
  @shows = u.shows.map { |s| s.name }
  slim :shows

end
