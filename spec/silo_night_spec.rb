ENV['APP_ENV'] = 'test'

require 'silo_night'

require 'rspec'
require 'rack/test'
require 'sinatra'

RSpec.describe 'Silo Night app' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "prompts to create a schedule" do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to include("Create")
  end

  it "creates a new schedule" do
    post '/'
    expect(last_response).to be_ok
  end

  it "lists your current shows" do
    get '/'
    expect(last_response).to be_ok
  end

end
