# spec/requests/api/v1/shows/update_spec.rb
require 'spec_helper'

RSpec.describe 'API v1 Shows Update', type: :request do
  before do
    user = User.create(name: 'sam')
    s1 = Show.create(name: 'Foundation')
    ShowMetadata.create(show_id: s1.id, provider_name: 'internal', external_id: 'foundation', payload: { runtime: '60' })
    s2 = Show.create(name: 'Silo')
    ShowMetadata.create(show_id: s2.id, provider_name: 'internal', external_id: 'silo', payload: { runtime: '60' })
    Services::UserShow.add_show(user, s1)
    Services::UserShow.add_show(user, s2)
  end

  it 'reorders shows and returns 200' do
    patch '/api/v1/user/sam/shows/Foundation', { position: 1 }.to_json, { 'CONTENT_TYPE' => 'application/json' }
    expect(last_response.status).to eq(200)
    expect(User.find(name: 'sam').shows.map(&:name)).to eq(['Silo', 'Foundation'])
  end
end
