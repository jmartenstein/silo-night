require 'spec_helper'
require 'rack/test'
require 'silo_night'

RSpec.describe 'API v1 Search', type: :request do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it 'returns a 200 OK and formatted search results' do
    get '/api/v1/search', { q: 'The Expanse' }

    expect(last_response.status).to eq(200)
    json = JSON.parse(last_response.body)
    expect(json).to be_an(Array)
    expect(json.first['name']).to eq('The Expanse')
  end
end
