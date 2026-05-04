# silo_night.rb

require 'sinatra'
require 'sinatra/contrib'
require 'slim'

$LOAD_PATH.unshift File.expand_path('./lib', __dir__)
require 'database'
require 'user'
require 'metadata_service'
require 'clock'
require 'services/schedule'
require 'services/show'
require 'services/user'
require 'services/user_config'
require 'services/user_show'
require 'presenters/show'
require 'presenters/user'
require 'presenters/schedule'
require 'presenters/tonight'
require 'presenters/error'
require 'presenters/search_result'
require 'services/search'

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

namespace '/api/v1' do

  # User Management
  post '/users' do
    content_type :json
    params = JSON.parse(request.body.read, symbolize_names: true)
    user = Services::User.create(params)
    unless user
      return [422, Presenters::Error.new("Username already exists", 422).to_h.to_json]
    end
    [201, Presenters::User.new(user).to_h.to_json]
  end

  delete '/users/:name' do
    content_type :json
    if Services::User.destroy(params[:name])
      return [204, ""]
    end
    [404, Presenters::Error.new("User not found", 404).to_h.to_json]
  end

  # Show Management
  get '/user/:name/shows' do
    content_type :json
    shows = Services::Show.list_for_user(params[:name])
    return [404, ""] unless shows
    shows.map { |s| Presenters::Show.new(s).to_h }.to_json
  end

  post '/user/:name/shows' do
    content_type :json
    user = User.find(name: params[:name])
    return [404, Presenters::Error.new("User not found", 404).to_h.to_json] unless user
    
    data = JSON.parse(request.body.read, symbolize_names: true)
    show = Show.find(name: data[:name])
    return [404, Presenters::Error.new("Show not found", 404).to_h.to_json] unless show
    
    Services::UserShow.add_show(user, show)
    [201, Presenters::Show.new(show).to_h.to_json]
  end

  delete '/user/:name/shows/:show_name' do
    content_type :json
    user = User.find(name: params[:name])
    unless user
      return [404, Presenters::Error.new("User not found", 404).to_h.to_json]
    end
    
    if Services::UserShow.remove_show(user, params[:show_name])
      return [204, ""]
    end
    [404, Presenters::Error.new("Show not found", 404).to_h.to_json]
  end

  patch '/user/:name/shows/:show_name' do
    content_type :json
    user = User.find(name: params[:name])
    unless user
      return [404, Presenters::Error.new("User not found", 404).to_h.to_json]
    end
    
    data = JSON.parse(request.body.read, symbolize_names: true)
    if Services::UserShow.reorder(user, params[:show_name], data[:position])
      return [200, ""]
    end
    [404, Presenters::Error.new("Show not found", 404).to_h.to_json]
  end

  # Schedule & Viewing
  get '/user/:name/schedule' do
    content_type :json
    user = User.find(name: params["name"])
    return [404, Presenters::Error.new("User not found", 404).to_json] unless user
    Services::Schedule.get_for_user(user).to_h.to_json
  end

  get '/user/:name/tonight' do
    content_type :json
    user = User.find(name: params["name"])
    return [404, Presenters::Error.new("User not found", 404).to_json] unless user
    schedule_data = user.schedule.is_a?(String) ? JSON.parse(user.schedule) : (user.schedule || {})
    today = Clock.today.strftime('%A')
    Presenters::Tonight.new(schedule_data, today).to_h.to_json
  end

  # Configuration
  get '/user/:name/config' do
    content_type :json
    user = User.find(name: params["name"])
    return [404, Presenters::Error.new("User not found", 404).to_json] unless user
    Services::UserConfig.get_for_user(user).to_json
  end

  post '/user/:name/config' do
    content_type :json
    user = User.find(name: params["name"])
    return [404, Presenters::Error.new("User not found", 404).to_json] unless user
    config_params = JSON.parse(request.body.read)
    Services::UserConfig.update_for_user(user, config_params)
    { status: 'success' }.to_json
  end

  # Search
  get '/search' do
    content_type :json
    query = params[:q]
    results = Services::Search.search(query)
    Presenters::SearchResult.new(results).to_json
  end
end

namespace '/api/v0.1' do
  before do
    logger.warn "DEPRECATION WARNING: Accessing v0.1 API endpoint: #{request.request_method} #{request.path_info}"
  end

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
    return status 404 if u.nil?
    sched = u.generate_schedule
    sched.to_json
  end

  get '/user/:name/schedule' do
    content_type :json
    u = User.find(name: params["name"])
    return status 404 if u.nil?
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

    s = Show.where(Sequel.function(:lower, :name) => params["show"].downcase).first

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
      Services::UserShow.add_show(u, s)
    end

    u.shows.map { |s| { name: s.name, runtime: s.runtime, poster_path: s.poster_path } }.to_json
  end

  delete '/user/:name/show/:show' do
    content_type :json

    u = User.find(name: params["name"])
    return status 404 if u.nil?
    s = Show.find(Sequel.ilike(:name, params["show"]))

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
