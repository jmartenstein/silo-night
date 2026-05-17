Given('a show named {string} exists in the local database with a poster') do |name|
  Services::ShowFactory.create_with_metadata(name)
end

When('I search for {string}') do |query|
  $browser.get "/api/v1/search", { q: query }
end

Then('I should see {string} in the results') do |name|
  expect($browser.last_response.body).to include(name)
end

Then('I should not see {string} in the results') do |name|
  expect($browser.last_response.body).not_to include(name)
end

Then('the page displays a suggestion for {string}') do |name|
  expect($browser.last_response.body).to include(name)
end

Then('I should see a {string} message') do |message|
  if $browser.last_response.headers['Content-Type'] =~ /json/ && message == "No shows found"
    expect(JSON.parse($browser.last_response.body)).to be_empty
  else
    expect($browser.last_response.body).to include(message)
  end
end
