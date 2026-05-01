require 'spec_helper'
require 'rack/test'
require 'silo_night'

RSpec.describe 'API v1 Schedule', type: :request do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  let(:user_name) { 'test_user' }
  let!(:user) { User.create(name: user_name) }
  
  # Setup a simple schedule
  before do
    user.update(schedule: { 'Monday' => [{ 'name' => 'The Expanse' }] }.to_json)
  end

  describe 'GET /api/v1/user/:name/schedule' do
    it 'returns a 200 OK and a full weekly schedule' do
      get "/api/v1/user/#{user_name}/schedule"

      expect(last_response.status).to eq(200)
      
      json = JSON.parse(last_response.body)
      
      # The contract: Every day must be present
      days = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday]
      expect(json.keys).to match_array(days)
      
      # Verify Monday has our show
      expect(json['Monday']).to be_an(Array)
      expect(json['Monday'].first['name']).to eq('The Expanse')
      
      # Verify Tuesday (which was empty in the DB) is present but empty
      expect(json['Tuesday']).to eq([])
    end
  end
end
