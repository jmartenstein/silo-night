# spec/requests/api/v1/shows/create_spec.rb
require 'spec_helper'

RSpec.describe 'API v1 Shows Create', type: :request do
  before do
    User.create(name: 'sam')
    s = Show.create(name: 'Foundation')
    ShowMetadata.create(show_id: s.id, provider_name: 'internal', external_id: 'foundation', payload: { runtime: '60' })
  end

  it 'adds a show to the users list and returns 201' do
    post '/api/v1/user/sam/shows', { name: 'Foundation' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
    expect(last_response.status).to eq(201)
    expect(User.find(name: 'sam').shows).to include(Show.find(name: 'Foundation'))
  end
end
