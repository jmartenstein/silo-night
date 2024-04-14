require 'user'
require 'rspec'

describe User do

  it "creates a new user with an empty config" do
    u = User.new.shows
    expect(u).to be_empty
  end

end
