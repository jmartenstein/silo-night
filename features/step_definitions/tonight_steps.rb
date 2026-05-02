# features/step_definitions/tonight_steps.rb

Given('a user {string} has shows scheduled for {string}') do |username, day|
  user = User.find(name: username) || User.create(name: username)
  # Use a simple schedule structure for the test
  schedule = { day => [{ 'name' => 'The Expanse' }] }
  user.update(schedule: schedule.to_json)
end

Given('today is {string}') do |day_name|
  # Map day name to a specific date for mocking
  # Monday = 2026-04-27, Tuesday = 2026-04-28, etc.
  days = { 'Monday' => '2026-04-27', 'Tuesday' => '2026-04-28', 'Wednesday' => '2026-04-29' }
  allow(Date).to receive(:today).and_return(Date.parse(days[day_name]))
end

When('{string} sends an API request for shows {string}') do |username, action|
  $browser.get "/api/v1/user/#{username}/#{action}"
end
