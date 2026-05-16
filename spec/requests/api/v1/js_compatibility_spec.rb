# spec/requests/api/v1/js_compatibility_spec.rb
require 'spec_helper'

RSpec.describe 'JavaScript API Compatibility', type: :request do
  let(:username) { 'sam' }
  let(:show_name) { 'Silo' }

  before do
    User.create(name: username)
    Show.create(name: show_name, runtime: '50', uri_encoded: 'silo')
  end

  describe 'Add Show (POST)' do
    context 'v0.1 style (as currently implemented in default.js for v1)' do
      it 'v0.1 endpoint passes with form-encoded params' do
        post "/api/v0.1/user/#{username}/show", { show: show_name }
        expect(last_response.status).to eq(200)
      end

      it 'v1 endpoint succeeds with v1-style request' do
        # We expect this to fail currently because the JS pattern doesn't match the v1 API contract yet
        post "/api/v1/user/#{username}/shows", { name: show_name }.to_json, { 'CONTENT_TYPE' => 'application/json' }
        expect(last_response.status).to eq(201)
      end
    end
  end

  describe 'Remove Show (DELETE)' do
    before do
      user = User.find(name: username)
      show = Show.find(name: show_name)
      Services::UserShow.add_show(user, show)
    end

    context 'v1 style' do
      it 'v1 endpoint succeeds with v1-style path' do
        # default.js currently uses /api/v1/user/.../show/:name
        # We want it to use /api/v1/user/.../shows/:name
        delete "/api/v1/user/#{username}/shows/#{show_name}"
        expect(last_response.status).to eq(204)
      end
    end
  end

  describe 'Reorder Shows (POST)' do
    before do
      user = User.find(name: username)
      show1 = Show.find(name: show_name)
      show2 = Show.create(name: 'Foundation', runtime: '60')
      Services::UserShow.add_show(user, show1)
      Services::UserShow.add_show(user, show2)
    end

    context 'v1 style' do
      let(:new_order) { ['Foundation', 'Silo'] }

      it 'v1 endpoint succeeds with bulk POST (if implemented)' do
        post "/api/v1/user/#{username}/shows/reorder", new_order.to_json, { 'CONTENT_TYPE' => 'application/json' }
        expect(last_response.status).to eq(200)

        user = User.find(name: username)
        expect(user.shows.map(&:name)).to eq(new_order)
      end
    end
  end
end
