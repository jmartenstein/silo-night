require 'user'
require 'rspec'

describe User do

  let(:testc1) {{ "config"  => { "days" => "m", "time" => "35m" },
                  "shows"   => [ "Platonic" ] }}
  let(:testc2) {{ "config"  => { "days" => "t", "time" => "60m" },
                  "shows"   => [ "Suits" ] }}

  it "creates a new user with an empty config" do
    u = User.new
    expect(u.shows).to be_empty
  end

  it "loads config from a data structure" do
    u = User.new(testc1)
    expect(u.config).to eq(testc1["config"])
  end

  it "loads shows from a data structure" do
    u = User.new(testc1)
    expect(u.shows).to eq(testc1["shows"])
  end

  it "displays show runtime" do
    u = User.new(testc1)
    u.expand_shows()
    expect(u.shows[0].class.name).to eq("Show")
    expect(u.shows[0].runtime).to eq ("30 minutes")
  end

  it "generates a first populated schedule" do
    u = User.new(testc1)
    u.generate_schedule()
    expect(u.schedule).not_to be_nil
    expect(u.schedule["Monday"]).to eq("Platonic")
  end

  it "generates a second populated schedule" do
    u = User.new(testc2)
    u.generate_schedule()
    expect(u.schedule["Tuesday"]).to eq("Suits")
  end

end
