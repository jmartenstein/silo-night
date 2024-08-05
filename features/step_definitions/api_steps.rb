# api_steps.rb

When('any user sends a request to the main page') do
  $browser.get '/'
end

When('{string} sends an API request for a list of shows') do |username|
  $browser.get "/api/v0.1/user/#{username}/shows"
end

When('{string} sends an API request to add {string} to the list') do |username,show|
  $browser.post "/api/v0.1/user/#{username}/show", "show"=>"#{show}"
end

When('{string} sends an API request to delete {string} from the list') do |username,show|
  $browser.delete "/api/v0.1/user/#{username}/show/#{show}"
end

When('{string} sends an API request to view the schedule') do |username|
  $browser.get "/api/v0.1/user/#{username}/schedule"
end

When('{string} generates a new schedule') do |username|
  $browser.put "/api/v0.1/user/#{username}/schedule"
end

Then('the site responds with JSON') do
  head = $browser.last_response.headers
  expect(head["Content-Type"]).to match("application/json")
end
