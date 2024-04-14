# api_steps.rb

When('any user sends a request to the main page') do
  $browser.get '/'
end

When('{string} sends a request for a list of shows') do |username|
  $browser.get "/user/#{username}/shows"
end

Then('the site responds with an OK code') do
  expect($browser.last_response).to be_ok
end

Then('the site responds with JSON containing {string}') do |show|
  expect($browser.last_response).to match(/Equalizer/)
end
