require 'spec_helper'
require 'rack/test'
require 'silo_night'

RSpec.describe 'API Poster Path' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  before(:each) do
    # Clear DB or setup test user
    User.where(name: 'testuser').delete
    Show.where(name: 'Suits').delete
    @user = User.create(name: 'testuser')
    @show = Show.create(name: 'Suits', runtime: '45 minutes', poster_path: 'https://example.com/suits.jpg')
  end

  it 'captures and returns poster_path when adding a new show' do
    post '/api/v1/user/testuser/shows', { name: 'Suits' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
    
    expect(last_response.status).to eq(201)
    json = JSON.parse(last_response.body)
    
    expect(json).not_to be_nil
    expect(json['poster_url']).to eq('https://example.com/suits.jpg')
    
    # Also check DB
    db_show = Show.find(name: 'Suits')
    expect(db_show.poster_path).to eq('https://example.com/suits.jpg')
  end
end
