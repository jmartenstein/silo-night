Given('a show named {string} exists in the local database with a poster') do |name|
  Show.create(name: name, poster_path: '/poster.jpg')
end

Then('the page displays a suggestion for {string}') do |name|
  actual_body = $browser.last_response.body.to_s
  expect(actual_body).to include(name)
end
