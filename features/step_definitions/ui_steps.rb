Given('the user {string} is on their shows and schedule page') do |username|
  @current_user_name = username
  User.find(name: username) || User.create(name: username, config: {}.to_json, schedule: {}.to_json)
  $browser.get "/user/#{username}/schedule/edit"
end

When('the user types {string} in the {string} field') do |value, field_id|
  # In a Rack::Test context, we simulate the AJAX call directly
  $browser.get "/api/v1/search?q=#{value}"
end

Then('the page displays a suggestion for {string} with {string} and {string}') do |name, genre, year|
  actual_body = $browser.last_response.body.to_s
  expect(actual_body).to include(name)
  expect(actual_body).to include(genre)
  expect(actual_body).to include(year)
end

When('the user searches for and adds {string}') do |name|
  # We assume the current page context from previous steps
  # If we need the username, we can pull it from the last request URL
  # In Rack::Test, we can access the last_request
  path = $browser.last_request.path_info
  username = path.split('/')[2]
  $browser.post "/api/v1/user/#{username}/shows", { "name" => name }.to_json
end

Then('the show {string} appears in the {string}') do |name, list_name|
  actual_body = $browser.last_response.body.to_s
  expect(actual_body).to include(name)
end

Then('the runtime {string} is displayed for {string}') do |runtime, name|
  actual_body = $browser.last_response.body.to_s
  expect(actual_body).to include(name)
  expect(actual_body).to include(runtime)
end

Given('the user {string} has {string} and {string} in their list') do |username, show1, show2|
  # Ensure user exists
  u = User.find(name: username) || User.create(name: username, config: {}.to_json, schedule: {}.to_json)
  
  # Ensure shows exist and are added to user
  [show1, show2].each do |name|
    show = Show.find(name: name) || Show.create(name: name, runtime: "45 minutes", uri_encoded: name.downcase.gsub(' ', '+'))
    Services::UserShow.add_show(u, show)
  end
end

When('the user drags {string} above {string}') do |show1, show2|
  # In Rack::Test, we simulate the reorder API call
  path = $browser.last_request.path_info
  username = path.split('/')[2]
  
  # We want show1 above show2. Let's assume the list was [show2, show1] and now it's [show1, show2]
  $browser.patch "/api/v1/user/#{username}/shows/#{show1}", { "position" => 0 }.to_json
  $browser.patch "/api/v1/user/#{username}/shows/#{show2}", { "position" => 1 }.to_json
end

Then('{string} is the first show in the list') do |name|
  if $browser.last_response.content_type == 'application/json'
    actual_body = JSON.parse($browser.last_response.body)
    first_show = actual_body.first
    first_name = first_show.is_a?(Hash) ? first_show['name'] : first_show
    expect(first_name).to eq(name)
  else
    # Check the HTML structure
    actual_body = $browser.last_response.body.to_s
    # In the HTML, the first show name is within span.name inside the first li of ul#show.list
    # Be flexible about attribute order
    first_match = actual_body.match(/<ul[^>]*id="show"[^>]*>.*?<span[^>]*class="name"[^>]*>([^<]+)<\/span>/m)
    expect(first_match[1].strip).to eq(name)
  end
end

When('any user visits the main page') do
  $browser.get '/'
end

When('the user {string} views her list of shows') do |username|
  @current_user_name = username
  User.find(name: username) || User.create(name: username, config: {}.to_json, schedule: {}.to_json)
  $browser.get "/user/#{username}/shows"
end

When('the user {string} visits the page to edit her shows') do |username|
  @current_user_name = username
  User.find(name: username) || User.create(name: username, config: {}.to_json, schedule: {}.to_json)
  $browser.get "/user/#{username}/schedule/edit"
end

When('any user visits the create new schedule page') do ||
  @current_user_name = "new_test_user"
  u = User.find(name: @current_user_name)
  u.delete if u
  User.create(name: @current_user_name, config: {}.to_json, schedule: {}.to_json)
  $browser.get "/user/#{@current_user_name}/schedule/edit"
end

Then('the page displays {string}') do |string|
  # Unescape HTML entities for comparison
  require 'cgi'
  actual_body = CGI.unescapeHTML($browser.last_response.body.to_s)
  expect(actual_body).to include(string)
end

Then('the page displays a form with {string} text') do |string|
  # Match either an input value, button text, or generic content inside a form
  actual_body = $browser.last_response.body.to_s
  expect(actual_body).to match(/<form.*#{string}.*<\/form>/m)
end

Then('a blank list of shows is displayed') do
  actual_body = $browser.last_response.body.to_s
  expect(actual_body).to match(/ul.*id="show"/)
  expect(actual_body).to match(/ul.*class="list"/)
  expect(actual_body).not_to match(/<li.*>.*<\/li>/)
end

Then('the show {string} displays its poster art') do |show_name|
  actual_body = $browser.last_response.body.to_s
  require 'nokogiri'
  doc = Nokogiri::HTML(actual_body)
  matching_li = doc.css('li').find do |li|
    name_span = li.at_css('span.name')
    next false unless name_span && name_span.text == show_name
    li.at_css('img.show-poster')
  end
  expect(matching_li).not_to be_nil
end

