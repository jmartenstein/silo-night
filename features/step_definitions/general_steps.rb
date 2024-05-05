# general_steps.rb

Then('the site responds with text containing {string}') do |show|
  expect($browser.last_response).to match(show)
end

Then('the site responds with an OK code') do
  expect($browser.last_response).to be_ok
end

