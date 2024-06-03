require 'user'
require 'rspec'
require 'spec_helper'

describe User do

  let(:bot_shows) { build_list(:show, 2) }

  let(:bot1_test) { build :user }
  let(:bot2_test) { build :user, name: "justin" }

  let(:seed_test) { User.find(name: "test") }
  let(:seed_just) { User.find(name: "justin") }

  it "loads a schedule from an existing file" do
    bot2_test.load_from_file("./data/justin.json")
    sched_str = bot2_test.values[:schedule]
    sched = JSON.parse(sched_str)
    expect(sched["Tuesday"]).to include("Suits")
  end

  it "confirm show class from user seed data" do
    expect(bot1_test.shows[0].class.name).to eq("Show")
  end

  it "checks for day in schedule" do
    actual = bot1_test.is_show_in_schedule?("foo")
    expect(actual).to be_truthy
  end

  it "finds next available slot for seeded user test" do
    next_slot = seed_test.find_next_available_slot("Suits")
    expect(next_slot).to eq("Monday")
  end

  it "checks if Tuesday is full in second seeded user's schedule" do
    seed_test.generate_schedule
    actual = seed_test.get_available_runtime_for_day("Tuesday")
    expect(actual).to eq(32)
  end

  it "generates populated schedule from first seeded user" do

    seed_just.generate_schedule()
    weekday = "Tuesday"

    sched = JSON.parse(seed_just.schedule)

    expect(sched).not_to be_nil
    expect(sched[weekday]).not_to be_empty
    expect(sched[weekday].length).to eq(2)
    expect(sched[weekday]).to include("Suits")

  end

  it "generates a second populated schedule" do

    seed_test.generate_schedule
    weekday = "Tuesday"

    sched = JSON.parse(seed_test.schedule)

    expect(sched[weekday]).not_to be_empty
    expect(sched[weekday][0]).to eq("His Dark Materials")

  end

end
