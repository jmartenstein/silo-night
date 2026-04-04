# spec/requests/api/v1/shows_spec.rb

require 'spec_helper'
require 'rack/test'
require 'silo_night'

RSpec.describe 'API v1 Shows', type: :request do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  let(:user_name) { 'test_user' }
  let!(:user) { User.create(name: user_name) }
  let!(:show1) { Show.create(name: 'The Expanse', runtime: 60, uri_encoded: 'the+expanse') }
  let!(:show2) { Show.create(name: 'Firefly', runtime: 45, uri_encoded: 'firefly') }

  before do
    user.add_show(show1)
    user.add_show(show2)
  end

  describe 'GET /api/v1/user/:name/shows' do
    it 'returns a 200 OK and a list of shows in the standardized format' do
      get "/api/v1/user/#{user_name}/shows"

      expect(last_response.status).to eq(200)
      
      json = JSON.parse(last_response.body)
      expect(json).to be_an(Array)
      expect(json.size).to eq(2)

      # Verify the standardized contract (ShowPresenter output)
      show_json = json.first
      expect(show_json).to have_key('id')
      expect(show_json).to have_key('name')
      expect(show_json).to have_key('runtime')
      expect(show_json).to have_key('uri_safe_name')
      expect(show_json).to have_key('poster_url')
    end
  end
end
