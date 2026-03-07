Given('the user {string} is on their shows and schedule page') do |username|
  $browser.get "/user/#{username}/schedule/edit"
end

When('the user types {string} in the {string} field') do |value, field_id|
  # In a Rack::Test context, we simulate the AJAX call directly
  $browser.get "/api/v0.1/search?q=#{value}"
end

Then('the page displays a suggestion for {string} with {string} and {string}') do |name, genre, year|
  actual_body = $browser.last_response.body.to_s
  expect(actual_body).to include(name)
  expect(actual_body).to include(genre)
  expect(actual_body).to include(year)
end

When('any user visits the main page') do
  $browser.get '/'
end

When('the user {string} views her list of shows') do |username|
  $browser.get "/user/#{username}/shows"
end

When('the user {string} visits the page to edit her shows') do |username|
  $browser.get "/user/#{username}/schedule/edit"
end

When('any user visits the create new schedule page') do ||
  $browser.get "schedule/new"
end

Then('the page displays {string}') do |string|
  # Unescape HTML entities for comparison
  require 'cgi'
  actual_body = CGI.unescapeHTML($browser.last_response.body.to_s)
  expect(actual_body).to include(string)
end

Then('the page displays a form with {string} text') do |string|
  form_string = $browser.last_response.body.to_s[/form(.*)form/,1]
  expect(form_string).to match(string)
end

Then('a blank list of shows is displayed') do
  pending
end
