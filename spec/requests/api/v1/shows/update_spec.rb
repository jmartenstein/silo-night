# spec/requests/api/v1/shows/update_spec.rb
require 'spec_helper'

RSpec.describe 'API v1 Shows Update', type: :request do
  before do
    user = create(:user, name: 'sam')
    show1 = create(:show, :with_metadata, name: 'Foundation', runtime: '60')
    show2 = create(:show, :with_metadata, name: 'Silo', runtime: '60')
    Services::UserShow.add_show(user, show1)
    Services::UserShow.add_show(user, show2)
  end

  it 'reorders shows and returns 200' do
    patch '/api/v1/user/sam/shows/Foundation', { position: 1 }.to_json, { 'CONTENT_TYPE' => 'application/json' }
    expect(last_response.status).to eq(200)
    expect(User.find(name: 'sam').shows.map(&:name)).to eq(['Silo', 'Foundation'])
  end
end
