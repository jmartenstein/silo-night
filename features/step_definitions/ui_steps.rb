When('any user visits the main page') do
  $browser.get '/'
end

When('the user {string} views her list of shows') do |username|
  $browser.get "/user/#{username}/shows"
end

When('the user {string} visits the page to edit her shows') do |username|
  $browser.get "/user/#{username}/schedule/edit"
end

When('any user visits the create new schedule page') do ||
  $browser.get "schedule/new"
end

Then('the page displays {string}') do |string|
  expect($browser.last_response).to match(string)
end

Then('the page displays a form with {string} text') do |string|
  form_string = $browser.last_response.body.to_s[/form(.*)form/,1]
  expect(form_string).to match(string)
end

Then('a blank list of shows is displayed') do
  pending
end
