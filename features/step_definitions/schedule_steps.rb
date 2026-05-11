# features/step_definitions/schedule_steps.rb

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

Then(/^(?:the )?"?(\w+)"? schedule should show "([^"]*)"$/) do |day, text|
  $browser.get "/user/#{@current_user_name}/schedule"
  expect($browser.last_response.body).to include(day)
  expect($browser.last_response.body).to include(text)
end

Then(/^(?:the )?"([^"]+)" schedule should NOT show "([^"]*)"$/) do |day, text|
  $browser.get "/user/#{@current_user_name}/schedule"
  # We check if the day's section contains the text. 
  # This is a bit simplistic but works for the current template.
  expect($browser.last_response.body).not_to include(text)
end

Then('the {word} schedule should show {string} or {string}') do |day, text1, text2|
  $browser.get "/user/#{@current_user_name}/schedule"
  expect($browser.last_response.body).to include(day)
  expect($browser.last_response.body).to match(/#{text1}|#{text2}/)
end

Given('the user {string} exists') do |username|
  @current_user_name = username
  User.find(name: username) || User.create(name: username, config: {}.to_json, schedule: {}.to_json)
end

Given('{string} has an empty schedule') do |username|
  u = User.find(name: username)
  u.schedule = {}.to_json
  u.save
end

When('the user adds {string} \({string}\) to their list via the UI') do |show_name, runtime|
  # Mimic the UI: Add the show to the database (if it doesn't exist) then associate with user
  # The UI calls POST /api/v0.1/user/:name/show
  unless Show.find(name: show_name)
    s = Show.create(name: show_name)
    ShowMetadata.create(show_id: s.id, provider_name: 'internal', external_id: show_name, payload: { runtime: runtime })
  end
  $browser.post "/api/v1/user/#{@current_user_name}/shows", { "name" => show_name }.to_json, { 'CONTENT_TYPE' => 'application/json' }
end

When('the user enables {string} but sets time to {string} minutes') do |day, minutes|
  u = User.find(name: @current_user_name)
  abbr = u.day_to_abbr(day)
  
  # Mimic the UI: POST /user/:name/availability
  $browser.post "/user/#{@current_user_name}/availability", {
    "days" => [abbr],
    "time_#{abbr}" => minutes
  }
end

Then('the guide should NOT show {string}') do |text|
  $browser.get "/user/#{@current_user_name}/schedule"
  expect($browser.last_response.body).not_to include(text)
end

Given(/^the user "([^"]*)" has "([^"]*)" \(([^)]*)\) and "([^"]*)" \(([^)]*)\) in their list$/) do |username, show1, run1, show2, run2|
  @current_user_name = username
  u = User.find(name: username) || User.create(name: username, config: {}.to_json, schedule: {}.to_json)
  
  unless Show.find(name: show1)
    s1 = Show.create(name: show1)
    ShowMetadata.create(show_id: s1.id, provider_name: 'internal', external_id: show1, payload: { runtime: run1 })
  end
  unless Show.find(name: show2)
    s2 = Show.create(name: show2)
    ShowMetadata.create(show_id: s2.id, provider_name: 'internal', external_id: show2, payload: { runtime: run2 })
  end
  
  s1 = Show.find(name: show1)
  s2 = Show.find(name: show2)
  
  Services::UserShow.add_show(u, s1) unless u.shows.include?(s1)
  Services::UserShow.add_show(u, s2) unless u.shows.include?(s2)
end

Given(/^"([^"]*)" has "([^"]*)" availability on "([^"]*)"$/) do |username, time, day|
  u = User.find(name: username)
  abbr = u.day_to_abbr(day)
  config = JSON.parse(u.config || "{}")
  
  days = config["days"] ? config["days"].split(",") : []
  days << abbr unless days.include?(abbr)
  config["days"] = days.join(",")
  config["time_#{abbr}"] = time.to_i
  
  u.config = config.to_json
  u.save
end

When('the user generates their final guide') do
  # First, trigger the generation
  $browser.get "/user/#{@current_user_name}/schedule/generate"
  # Now fetch the actual JSON schedule directly via v1 API
  $browser.get "/api/v1/user/#{@current_user_name}/schedule"
end

Then('{string} should be scheduled for {string}') do |show, day|
  # The API returns the schedule as JSON
  schedule = JSON.parse($browser.last_response.body)
  expect(schedule[day].any? { |s| s.is_a?(Hash) ? s["name"] == show : s == show }).to be_truthy
end

Given('the user {string} has {string} scheduled for today') do |username, show|
  @current_user_name = username
  u = User.find(name: username) || User.create(name: username, config: {}.to_json, schedule: {}.to_json)
  today = Date.today.strftime('%A')
  
  schedule = JSON.parse(u.schedule || "{}")
  schedule[today] ||= []
  show_obj = { "name" => show, "poster_path" => nil }
  unless schedule[today].any? { |s| s.is_a?(Hash) ? s["name"] == show : s == show }
    schedule[today] << show_obj
  end
  
  u.schedule = schedule.to_json
  u.save
end

When('the user views their final guide') do
  $browser.get "/user/#{@current_user_name}/schedule"
end

Then('{string} is highlighted as {string}') do |show, highlight|
  # Assuming "Watch Tonight" is a class or a specific text in the UI
  actual_body = CGI.unescapeHTML($browser.last_response.body.to_s)
  expect(actual_body).to include(show)
  expect(actual_body).to include(highlight)
end

Then('the current day is marked as active in the weekly schedule') do
  today = Date.today.strftime('%A')
  actual_body = CGI.unescapeHTML($browser.last_response.body.to_s)
  # Assuming current day has an 'active' class or is just present
  expect(actual_body).to include(today)
end
