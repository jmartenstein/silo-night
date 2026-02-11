# silo_night.rb

require 'sinatra'
require 'sinatra/contrib'
require 'slim'

require 'sequel'
require 'sequel/extensions/migration'
require 'user'

# set slim templates to custom diectory
set :views, File.expand_path(File.join(__FILE__, '../template'))

# load the databae
db = Sequel.connect('sqlite://data/silo_night.db')

# Ensure migrations are current
unless Sequel::Migrator.is_current?(db, 'db/migrations')
  warn "WARNING: Database migrations are not up to date. Run 'rake db:migrate' to update."
end

get '/' do
  @users = User.map { |x| x[:name] }
  slim :index
end

get '/user/:name/schedule' do
  @schedule = JSON.parse(User.find(name: params["name"]).schedule)
  slim :schedule
end

get '/user/:name/schedule/edit' do
  @shows = User.find(name: params["name"]).shows
  @config = User.find(name: params["name"]).config
  slim :schedule_edit
end

namespace '/api/v0.1' do

  delete '/user/:name' do
    content_type :json

    # delete each of the user show links
    u = User.find(name: params["name"])

    if u.nil?
      status 404
    else
      show_list = u.shows
      show_list.each do |s|
        u.remove_show(s)
      end

      # delete the user itself
      u.delete
      "user #{params["name"]}' deleted"
    end

  end

  put '/user/:name' do
    content_type :json

    # does the user already exist?
    u = User.find(name: params["name"])

    if u.nil?

      # create new user from name
      u = User.new
      u["name"] = params["name"]
      u.save

      # load shows from json
      u.load_from_json_string(request.body.read, true)
      u.save

      # return user name
      return params["name"]

    else
      return "user '#{params["name"]}' already exists"
    end

  end

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

  get '/user/:name/config' do
    content_type :json
    u = User.find(name: params["name"])
    u.config
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
      status 404
    else
      u.add_show(s)
    end

    u.shows.map { |s| s.name }.to_json

  end

  delete '/user/:name/show/:show' do
    content_type :json

    parser = URI::Parser.new

    u = User.find(name: params["name"])
    s = Show.find(uri_encoded: parser.escape(params["show"]))

    if s.nil? then
      status 404
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

  get '/user/:name/show_uris' do
    content_type :json
    u = User.find(name: params["name"])
    u.shows.map { |s| s.uri_encoded }.to_json
  end

end

get '/user/:name/shows' do

  # lookup user_id based on name
  u = User.find(name: params["name"])
  @shows = u.shows.map { |s| s.name }
  slim :shows

end
