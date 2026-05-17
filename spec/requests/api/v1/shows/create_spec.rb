# spec/requests/api/v1/shows/create_spec.rb
require 'spec_helper'

RSpec.describe 'API v1 Shows Create', type: :request, type: :integration do
  before do
    create(:user, name: 'sam')
    create(:show, :with_metadata, name: 'Foundation', runtime: '60')
  end

  it 'adds a show to the users list and returns 201' do
    post '/api/v1/user/sam/shows', { name: 'Foundation' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
    expect(last_response.status).to eq(201)
    expect(User.find(name: 'sam').shows).to include(Show.find(name: 'Foundation'))
  end

  it 'persists metadata when a new show is created via metadata' do
    # Using a show name that would trigger MetadataService logic
    VCR.use_cassette('tmdb/search_shows') do
      post '/api/v1/user/sam/shows', { name: 'Slow Horses' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
    end
    
    show = Show.find(name: 'Slow Horses')
    expect(show).not_to be_nil
    expect(show.metadata).not_to be_nil
    expect(show.metadata.payload).to be_a(Hash)
    expect(show.metadata.payload['name']).to eq('Slow Horses')
  end

  it 'links metadata to the correct show_id' do
    VCR.use_cassette('tmdb/search_shows') do
      post '/api/v1/user/sam/shows', { name: 'Slow Horses' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
    end
    
    show = Show.find(name: 'Slow Horses')
    expect(show.metadata.show_id).to eq(show.id)
  end
end
