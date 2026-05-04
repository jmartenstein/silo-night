# api_steps.rb

When('any user sends a request to the main page') do
  $browser.get '/'
end

When('{string} sends an API request for a list of shows') do |username|
  $browser.get "/api/v1/user/#{username}/shows"
end

When('{string} sends an API request to add {string} to the list') do |username,show|
  $browser.post "/api/v1/user/#{username}/shows", { "name" => "#{show}" }.to_json
end

When('{string} sends an API request to delete {string} from the list') do |username,show|
  $browser.delete "/api/v1/user/#{username}/shows/#{show}"
end

When('{string} sends an API request to view the schedule') do |username|
  $browser.get "/api/v1/user/#{username}/schedule"
end

When('{string} generates a new schedule') do |username|
  # Note: generation is now part of the POST /api/v1/user/:name/config or implicit
  # Based on silo_night.rb: 
  # POST '/user/:name/availability' triggers generate_schedule
  # The v0.1 put '/user/:name/schedule' just returned generate_schedule result.
  # We should probably use the new Service logic, but for testing, let's trigger it.
  $browser.get "/user/#{username}/schedule/generate"
end

Then('the site responds with JSON') do
  head = $browser.last_response.headers
  expect(head["Content-Type"]).to match("application/json")
end
