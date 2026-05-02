require 'spec_helper'
require 'rack/test'
require 'silo_night'

RSpec.describe 'API v1 Tonight', type: :request do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  let(:user) { User.create(name: 'steph') }

  before do
    user.update(schedule: { 'Monday' => [{ 'name' => 'The Expanse' }] }.to_json)
    # Stubbing Date.today to Monday 2026-04-27
    allow(Date).to receive(:today).and_return(Date.parse('2026-04-27'))
  end

  it 'returns a 200 OK and only the shows for today' do
    get "/api/v1/user/#{user.name}/tonight"

    expect(last_response.status).to eq(200)
    
    json = JSON.parse(last_response.body)
    expect(json).to be_an(Array)
    expect(json.first['name']).to eq('The Expanse')
  end
end
