#  features/step_definitions/user_steps.rb

Given('there are existing users {string} and {string}') do |user1, user2|
  User.find(name: user1) || User.create(name: user1, config: {}.to_json, schedule: {}.to_json)
  User.find(name: user2) || User.create(name: user2, config: {}.to_json, schedule: {}.to_json)
end

Given('there is an existing user {string}') do |username|
  User.find(name: username) || User.create(name: username, config: {}.to_json, schedule: {}.to_json)
end

When('the user enters {string} in the {string} field') do |value, field_name|
  @form_data ||= {}
  @form_data[field_name] = value
end

When('the user clicks the {string} button') do |button_text|
  if ["Create", "Enter"].include?(button_text)
    # Assuming user creation is via POST to /user/create
    # Need to verify where this form should post.
    # Looking at the requirement, it should likely be a POST to /user
    $browser.post '/user', @form_data
    $browser.follow_redirect! if $browser.last_response.redirect?
  end
end

When('the user clicks on the name {string}') do |username|
  $browser.get "/user/#{username}/schedule"
end
