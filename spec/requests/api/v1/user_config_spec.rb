require 'spec_helper'
require 'rack/test'
require 'silo_night'

RSpec.describe 'API v1 User Config', type: :request do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  let(:user) { User.create(name: 'steph', config: { 'days' => 'm' }.to_json) }

  describe 'GET /api/v1/user/:name/config' do
    it 'returns the user configuration' do
      get "/api/v1/user/#{user.name}/config"

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json['days']).to eq('m')
    end
  end

  describe 'POST /api/v1/user/:name/config' do
    it 'updates the user configuration' do
      post "/api/v1/user/#{user.name}/config", { 'days' => 't,w' }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      expect(last_response.status).to eq(200)
      user.reload
      expect(JSON.parse(user.config)['days']).to eq('t,w')
    end
  end
end
