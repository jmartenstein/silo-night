# api_steps.rb

When('any user sends a request to the main page') do
  $browser.get '/'
end

Then('the site responds with an OK code') do
  expect($browser.last_response).to be_ok
end
