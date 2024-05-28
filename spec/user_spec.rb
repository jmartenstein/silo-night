require 'user'
require 'rspec'

describe User do

  before :context do
    @new_user = User.new(config: "days",
                         schedule: "{ \"Tuesday\": [\"foo\"] }")
    @seeded_user_justin = User.find(name: "justin")
    @seeded_user_test = User.find(name: "test")
  end

  it "loads config from a data structure" do
    expect(@new_user.values[:config]).to eq("days")
  end

  it "loads a schedule from a file" do

    u = User.new()
    u.load_from_file("./data/justin.json")

    sched_str = u.values[:schedule]
    sched = JSON.parse(sched_str)

    expect(sched["Tuesday"]).to include("Suits")

  end

  it "confirm show class from user seed data" do
    expect(@seeded_user_justin.shows[0].class.name).to eq("Show")
  end

  it "checks for day in schedule" do
    actual = @new_user.is_show_in_schedule?("foo")
    expect(actual).to be_truthy
  end

  it "finds next available slot for seeded user justin" do
    next_slot = @seeded_user_justin.find_next_available_slot("Platonic")
    expect(next_slot).to eq("Monday")
  end

  it "finds next available slot for seeded user test" do
    next_slot = @seeded_user_test.find_next_available_slot("Suits")
    expect(next_slot).to eq("Monday")
  end

  it "checks if time is available for Sunday in seeded data" do
    expect(@seeded_user_justin.get_available_runtime_for_day("Monday")).to eq(37)
  end

  it "checks if Tuesday is full in second seeded user's schedule" do

    @seeded_user_test.generate_schedule
    actual = @seeded_user_test.get_available_runtime_for_day("Tuesday")
    expect(actual).to eq(32)

  end

  it "generates populated schedule from first seeded user" do

    @seeded_user_justin.generate_schedule()
    weekday = "Tuesday"

    sched = JSON.parse(@seeded_user_justin.schedule)

    expect(sched).not_to be_nil
    expect(sched[weekday]).not_to be_empty
    expect(sched[weekday].length).to eq(2)
    expect(sched[weekday]).to include("Suits")

  end

  it "generates a second populated schedule" do

    @seeded_user_test.generate_schedule
    weekday = "Tuesday"

    sched = JSON.parse(@seeded_user_test.schedule)

    expect(sched[weekday]).not_to be_empty
    expect(sched[weekday][0]).to eq("His Dark Materials")

  end

end
