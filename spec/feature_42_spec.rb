ENV['APP_ENV'] = 'test'
require 'silo_night'
require 'rack/test'
require 'rspec'

RSpec.describe 'Focused Execution View (Issue #42)' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:all) do
    # Ensure test migrations are run
    unless Sequel::Migrator.is_current?(DB, 'db/migrations')
      Sequel::Migrator.run(DB, 'db/migrations')
    end
  end

  let!(:user) { User.create(name: 'testuser', config: {}.to_json, schedule: { "Monday" => ["Show A"] }.to_json) }

  it "renders the schedule view without the generic header" do
    get "/user/#{user.name}/schedule"
    expect(last_response).to be_ok
    expect(last_response.body).not_to include("Shows and Schedule for")
  end

  it "contains the 'Return to Plan' action" do
    get "/user/#{user.name}/schedule"
    expect(last_response).to be_ok
    expect(last_response.body).to include("Return to Plan")
    expect(last_response.body).to include("href=\"schedule/edit\"")
  end

  it "includes day rows with correct classes" do
    get "/user/#{user.name}/schedule"
    expect(last_response).to be_ok
    today = Date.today.strftime('%A')
    expect(last_response.body).to include("active-day") if user.schedule.include?(today)
    expect(last_response.body).to include("day-row")
    expect(last_response.body).to include("day-name")
  end

  it "shows the correct day name" do
    get "/user/#{user.name}/schedule"
    expect(last_response).to be_ok
    expect(last_response.body).to include("Monday")
  end
end
