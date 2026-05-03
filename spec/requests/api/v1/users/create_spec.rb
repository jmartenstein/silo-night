# spec/requests/api/v1/users/create_spec.rb
require 'spec_helper'

RSpec.describe 'API v1 Users Create', type: :request do
  it 'creates a new user and returns 201' do
    post '/api/v1/users', { name: 'NewUser' }.to_json
    expect(last_response.status).to eq(201)
    expect(JSON.parse(last_response.body)['name']).to eq('NewUser')
  end

  it 'returns 422 if username already exists' do
    User.create(name: 'ExistingUser')
    post '/api/v1/users', { name: 'ExistingUser' }.to_json
    expect(last_response.status).to eq(422)
  end
end
