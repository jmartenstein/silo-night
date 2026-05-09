RSpec.describe 'Silo Night app' do
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  it "prompts to create a new user" do
    get '/'
    expect(last_response).to be_ok
    expect(last_response.body).to include("Enter")
  end

end
