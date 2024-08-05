# general_steps.rb

Then('the site responds with text containing {string}') do |show|
  expect($browser.last_response).to match(show)
end

Then('the site responds with text not containing {string}') do |show|
  expect($browser.last_response).not_to match(show)
end

Then('the show {string} is scheduled for {string}') do |show, weekday|
  response_body = $browser.last_response.body
  j = JSON.parse(response_body)
  expect(j[weekday]).to include(show)
end

Then('the site responds with an OK code') do
  expect($browser.last_response).to be_ok
end

Then('the site responds with a 404 error code') do
  p $browser.last_response.status
  expect($browser.last_response.status).to eq(404)
end

