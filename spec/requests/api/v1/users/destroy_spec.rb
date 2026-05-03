# spec/requests/api/v1/users/destroy_spec.rb
require 'spec_helper'

RSpec.describe 'API v1 Users Destroy', type: :request do
  it 'deletes an existing user and returns 204' do
    User.create(name: 'ToDelete')
    delete '/api/v1/users/ToDelete'
    expect(last_response.status).to eq(204)
    expect(User.find(name: 'ToDelete')).to be_nil
  end

  it 'returns 404 if user does not exist' do
    delete '/api/v1/users/Unknown'
    expect(last_response.status).to eq(404)
  end
end
