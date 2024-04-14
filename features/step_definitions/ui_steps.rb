When('a user visits the main page') do
  $browser.get '/'
end

Then('the welcome page displays {string}') do |string|
  expect(true).to be false
end

When('the user {string} views her list of shows') do |username|
  $browser.get "/user/#{username}/shows"
end

Then('the list page displays {string} and {string}') do |show1, show2|
  expect(true).to be false
end
