# spec/requests/api/v1/shows/update_spec.rb
require 'spec_helper'

RSpec.describe 'API v1 Shows Update', type: :request do
  before do
    user = User.create(name: 'sam')
    show1 = Show.create(name: 'Foundation', average_runtime: 60)
    show2 = Show.create(name: 'Silo', average_runtime: 60)
    Services::UserShow.add_show(user, show1)
    Services::UserShow.add_show(user, show2)
  end

  it 'reorders shows and returns 200' do
    patch '/api/v1/user/sam/shows/Foundation', { position: 1 }.to_json
    expect(last_response.status).to eq(200)
    expect(User.find(name: 'sam').shows).to eq(['Silo', 'Foundation'])
  end
end
