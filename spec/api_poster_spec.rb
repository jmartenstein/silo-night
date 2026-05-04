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
  end

  it 'captures and returns poster_path when adding a new show' do
    # Mock MetadataService to return a poster_path
    allow_any_instance_of(MetadataService).to receive(:get_show_metadata).and_return({
      name: 'Suits',
      runtime: '45 minutes',
      poster_path: 'https://example.com/suits.jpg'
    })

    post '/api/v1/user/testuser/shows', { name: 'Suits' }.to_json
    
    expect(last_response).to be_ok
    json = JSON.parse(last_response.body)
    
    show = json.find { |s| s['name'] == 'Suits' }
    expect(show).not_to be_nil
    expect(show['poster_path']).to eq('https://example.com/suits.jpg')
    
    # Also check DB
    db_show = Show.find(name: 'Suits')
    expect(db_show.poster_path).to eq('https://example.com/suits.jpg')
  end
end
