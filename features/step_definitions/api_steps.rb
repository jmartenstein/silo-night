# api_steps.rb

When('any user sends a request to the main page') do
  $browser.get '/'
end

When('{string} sends an API request for a list of shows') do |username|
  $browser.get "/api/v0.1/user/#{username}/shows"
end

Then('the site responds with JSON') do
  head = $browser.last_response.headers
  expect(head["Content-Type"]).to match("application/json")
end
