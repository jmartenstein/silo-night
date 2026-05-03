# features/step_definitions/tonight_steps.rb
require 'clock'

Given('a user {string} has shows scheduled for {string}') do |username, day|
  user = User.find(name: username) || User.create(name: username)
  schedule = { day => [{ 'name' => 'The Expanse' }] }
  user.update(schedule: schedule.to_json)
end

Given('today is {string}') do |day_name|
  days = { 'Monday' => '2026-04-27', 'Tuesday' => '2026-04-28', 'Wednesday' => '2026-04-29' }
  Clock.set_today(Date.parse(days[day_name]))
end

After do
  Clock.set_today(nil)
end

When('{string} sends an API request for shows {string}') do |username, action|
  $browser.get "/api/v1/user/#{username}/#{action}"
end
