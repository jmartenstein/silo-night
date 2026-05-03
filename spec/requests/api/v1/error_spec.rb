require 'spec_helper'
require 'rack/test'
require 'silo_night'

RSpec.describe 'API v1 Error Handling', type: :request do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it 'returns a standardized JSON error structure for 404s' do
    get '/api/v1/user/non_existent_user/schedule'

    expect(last_response.status).to eq(404)
    
    json = JSON.parse(last_response.body)
    expect(json).to have_key('error')
    expect(json['error']).to have_key('message')
    expect(json['error']).to have_key('code')
    expect(json['error']['code']).to eq(404)
  end
end
