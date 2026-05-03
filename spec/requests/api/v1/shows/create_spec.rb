# spec/requests/api/v1/shows/create_spec.rb
require 'spec_helper'

RSpec.describe 'API v1 Shows Create', type: :request do
  before { User.create(name: 'sam') }

  it 'adds a show to the users list and returns 201' do
    post '/api/v1/user/sam/shows', { name: 'Foundation' }.to_json, { 'CONTENT_TYPE' => 'application/json' }
    expect(last_response.status).to eq(201)
    expect(User.find(name: 'sam').shows).to include(Show.find(name: 'Foundation'))
  end
end
