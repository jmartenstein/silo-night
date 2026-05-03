# spec/requests/api/v1/shows/destroy_spec.rb
require 'spec_helper'

RSpec.describe 'API v1 Shows Destroy', type: :request do
  before do
    user = User.create(name: 'sam')
    show = Show.create(name: 'Foundation', average_runtime: 60)
    Services::UserShow.add_show(user, show)
  end

  it 'removes a show from the list and returns 204' do
    delete '/api/v1/user/sam/shows/Foundation'
    expect(last_response.status).to eq(204)
    expect(User.find(name: 'sam').shows).not_to include('Foundation')
  end
end
