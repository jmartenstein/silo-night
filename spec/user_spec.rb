require 'user'
require 'rspec'

describe User do

  let(:testc1) {{ "config"  => { "days" => "t", "time" => "10m" },
                  "shows"   => [ "foo" ] }}
  let(:testc2) {{ "config"  => { "days" => "t", "time" => "12m" },
                  "shows"   => [ "bar" ] }}

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

  it "deletes a show from the list" do
    u = User.new(testc1)
    u.delete_show("foo")
    expect(u.shows).to be_empty
  end

  it "add a show to the list" do
    u = User.new(testc1)
    u.add_show("baz")
    expect(u.shows).to include("foo", "baz")
  end

  it "displays show runtime" do
    u = User.new(testc1)
    u.expand_shows()
    expect(u.shows[0].class.name).to eq("Show")
    expect(u.shows[0].runtime).to eq ("4-6 minutes")
  end

  it "generates a first populated schedule" do
    u = User.new(testc1)
    u.generate_schedule()
    expect(u.schedule).not_to be_nil
    expect(u.schedule["tuesday"][0]).to eq("foo")
  end

  it "generates a second populated schedule" do
    u = User.new(testc2)
    u.generate_schedule()
    expect(u.schedule["tuesday"][0]).to eq("bar")
  end

end
