# features/step_definitions/schedule_steps.rb

Given('the user {string} is on their shows and schedule page') do |username|
  @current_user_name = username
  User.find(name: username) || User.create(name: username, config: {}.to_json, schedule: {}.to_json)
  $browser.get "/user/#{username}/schedule"
end

When('the user sets the available time for {string} to {string} minutes') do |day, minutes|
  u = User.find(name: @current_user_name)
  abbr = u.day_to_abbr(day)
  
  config = JSON.parse(u.config || "{}")
  days = config["days"] ? config["days"].split(",") : []
  days << abbr unless days.include?(abbr)
  
  $browser.post "/user/#{@current_user_name}/availability", {
    "days" => days,
    "time_#{abbr}" => minutes
  }
end

When('the user sets {string} as {string}') do |day, status|
  if status == "Unavailable"
    u = User.find(name: @current_user_name)
    abbr = u.day_to_abbr(day)
    
    config = JSON.parse(u.config || "{}")
    days = config["days"] ? config["days"].split(",") : []
    days.delete(abbr)
    
    $browser.post "/user/#{@current_user_name}/availability", {
      "days" => days
    }
  end
end

Then('the Monday schedule should show {string}') do |text|
  $browser.get "/user/#{@current_user_name}/schedule"
  expect($browser.last_response.body).to include("Monday")
  expect($browser.last_response.body).to include(text)
end

Then('the Tuesday schedule should show {string} or {string}') do |text1, text2|
  $browser.get "/user/#{@current_user_name}/schedule"
  expect($browser.last_response.body).to include("Tuesday")
  actual_body = CGI.unescapeHTML($browser.last_response.body.to_s)
  expect(actual_body.match(text1) || actual_body.match(text2)).to be_truthy
end
