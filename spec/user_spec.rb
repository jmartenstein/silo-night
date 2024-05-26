require 'user'
require 'rspec'

describe User do

  let(:testc1) {{ "config"   => { "days" => [ "t", "w" ], "time" => "10m" },
                  "shows"    => [ "foo", "bar", "baz" ],
                  "schedule" => {
                     "Tuesday" => [ "foo" ],
                     "Wednesday" => [ "baz" ]
                   }
               }}
  
  let(:testc2) {{ "config"  => { "days" => [ "t", "w" ], "time" => "12m" },
                  "shows"   => [ "bar", "foo" ] }}

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

  it "loads a schedule from a file" do

    u = User.new()
    u.load_from_file("./data/justin.json")
    sched = u.schedule

    expect(sched["monday"]).to include("Reacher")

  end

  it "deletes a show from the list" do
    u = User.new(testc2)
    u.delete_show("bar")
    expect(u.shows).to include("foo")
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
    expect(u.shows[1].class.name).to eq("Show")
    expect(u.shows[1].runtime).to eq ("5 minutes")
  end

  it "finds next available slot for user 1" do
    u = User.new(testc1)
    expect(u.find_next_available_slot("bar")).to eq("Tuesday")
  end

  it "finds next available slot fo user 2" do
    u = User.new(testc2)
    expect(u.find_next_available_slot("bar")).to eq("Tuesday")
  end

  it "checks if time is available for Wednesday" do  
    u = User.new(testc1)
    expect(u.get_available_runtime_for_day("Wednesday")).to eq(7)
  end

  it "checks if Tuesday is full in second user's schedule" do

    u = User.new(testc2)
    u.generate_schedule

    actual = u.get_available_runtime_for_day("Tuesday")
    expect(actual).to eq(2)

  end

  it "generates a first populated schedule" do

    u = User.new(testc1)
    weekday = "Tuesday"

    u.generate_schedule()

    expect(u.schedule).not_to be_nil
    expect(u.schedule[weekday]).not_to be_empty
    expect(u.schedule[weekday].length).to eq(2)
    expect(u.schedule[weekday]).to include("foo")

  end

  it "generates a second populated schedule" do

    u = User.new(testc2)
    weekday = "Tuesday"

    u.generate_schedule()
    #p u.schedule
    
    expect(u.schedule[weekday]).not_to be_empty
    expect(u.schedule[weekday][0]).to eq("bar")

  end

end
