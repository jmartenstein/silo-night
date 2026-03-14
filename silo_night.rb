# silo_night.rb

require 'sinatra'
require 'sinatra/contrib'
require 'slim'

$LOAD_PATH.unshift File.expand_path('./lib', __dir__)
require 'database'
require 'user'
require 'metadata_service'

# set slim templates to custom diectory
set :views, File.expand_path(File.join(__FILE__, '../template'))

configure :development do
  set :protection, true
end

configure :production do
  set :protection, true
end

configure :test do
  set :protection, false
end

# Ensure migrations are current
unless Sequel::Migrator.is_current?(DB, 'db/migrations')
  warn "WARNING: Database migrations are not up to date. Run 'rake db:migrate' to update."
end

get '/' do
  @users = User.map { |x| x[:name] }
  slim :index
end

post '/user' do
  username = params[:username]
  if username.nil? || username.strip.empty?
    @error = "Username cannot be empty"
    @users = User.map { |x| x[:name] }
    return slim :index
  end

  if User.find(name: username)
    @error = "Username '#{username}' already exists. Please choose a different one."
    @users = User.map { |x| x[:name] }
    return slim :index
  end

  User.create(name: username, config: {}.to_json, schedule: {}.to_json)
  redirect "/user/#{username}/schedule/edit"
end

get '/user/:name/schedule' do
  @user = User.find(name: params["name"])
  @schedule = JSON.parse(@user.schedule || "{}")
  slim :schedule
end

get '/user/:name/schedule/generate' do
  @user = User.find(name: params["name"])
  @user.generate_schedule
  redirect "/user/#{params[:name]}/schedule"
end

get '/user/:name/schedule/edit' do
  @user = User.find(name: params["name"])
  if @user.nil?
    status 404
    return "User not found"
  end
  @shows = @user.shows
  @config = JSON.parse(@user.config || "{}")
  slim :schedule_edit
end

post '/user/:name/availability' do
  @user = User.find(name: params["name"])
  config = JSON.parse(@user.config || "{}")

  # Update enabled days
  config["days"] = params["days"] ? params["days"].join(",") : ""

  # Update per-day times
  ["s", "m", "t", "w", "th", "f", "sa"].each do |abbr|
    config["time_#{abbr}"] = params["time_#{abbr}"] if params["time_#{abbr}"]
  end

  @user.config = config.to_json
  @user.generate_schedule
  @user.save

  @shows = @user.shows
  @config = config
  @message = "Availability updated successfully"
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
    u = User.find(name: params["name"])
    return status 404 if u.nil?

    today = Date.today.strftime('%A')
    j = JSON.parse(u.schedule || "{}")

    (j[today] || []).to_json

  end

  post '/user/:name/show' do
    content_type :json

    u = User.find(name: params["name"])
    return status 404 if u.nil?

    s = Show.find(name: params["show"])

    if s.nil?
      # Try to fetch metadata and create the show
      service = MetadataService.new
      metadata = service.get_show_metadata(params["show"])
      
      if metadata
        require 'uri'
        s = Show.create(
          name: metadata[:name],
          runtime: metadata[:runtime],
          uri_encoded: URI.encode_www_form_component(metadata[:name].downcase),
          poster_path: metadata[:poster_path]
        )
      end
    end

    if s.nil?
      status 404
    else
      u.add_show(s) unless u.shows.include?(s)
      u.generate_schedule
    end

    u.shows.map { |s| { name: s.name, runtime: s.runtime, poster_path: s.poster_path } }.to_json
  end

  delete '/user/:name/show/:show' do
    content_type :json

    u = User.find(name: params["name"])
    s = Show.find(name: params["show"])

    if s.nil? then
      status 404
    else
      u.remove_show(s)
      u.generate_schedule
    end

    u.shows.map { |s| { name: s.name, runtime: s.runtime, poster_path: s.poster_path } }.to_json

  end

  post '/user/:name/shows/reorder' do
    content_type :json
    u = User.find(name: params["name"])
    return status 404 if u.nil?

    new_order = JSON.parse(request.body.read)
    # new_order is an array of show names
    
    DB.transaction do
      new_order.each_with_index do |show_name, index|
        show = Show.find(name: show_name)
        if show
          DB[:shows_users].where(user_id: u.id, show_id: show.id).update(show_order: index)
        end
      end
    end
    u.generate_schedule

    u.shows.map { |s| { name: s.name, runtime: s.runtime, poster_path: s.poster_path } }.to_json
  end

  get '/user/:name/shows' do
    content_type :json
    u = User.find(name: params["name"])
    return status 404 if u.nil?
    u.shows.map { |s| s.name }.to_json
  end

  get '/user/:name/show_uris' do
    content_type :json
    u = User.find(name: params["name"])
    return status 404 if u.nil?
    u.shows.map { |s| s.uri_encoded }.to_json
  end

  get '/search' do
    content_type :json
    service = MetadataService.new
    results = service.search_shows(params[:q])
    results.to_json
  end

end

get '/user/:name/shows' do

  # lookup user_id based on name
  u = User.find(name: params["name"])
  @shows = u.shows.map { |s| s.name }
  slim :shows

end
