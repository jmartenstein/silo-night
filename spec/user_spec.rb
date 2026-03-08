require 'user'
require 'rspec'
require 'spec_helper'

describe User do

  let(:bot_shows) { build_list(:show, 3) do |show, i|
    show.name = "show" + i.to_s
    show.values[:show_order] = i
  end }

  let(:bot1_test) { build :user }
  let(:bot2_test) { build :user, name: "justin" }

  #let(:seed_test) { User.find(name: "steph") }
  let(:seed_just) { User.find(name: "justin") }

  it "loads a schedule from an existing file" do
    bot1_test.load_from_file("./data/test.json")
    sched_str = bot1_test.values[:schedule]
    sched = JSON.parse(sched_str)
    expect(sched["Tuesday"]).to include("Suits")
  end

  it "modifies the show order" do

    # build a stub of how we expect bot1_test shows_dataset to behave
    allow(bot1_test).to receive_message_chain(:shows_dataset,
                                              :all).and_return(bot_shows)
    list_of_shows = bot1_test.shows_dataset.all

    # confirm that the factory bot has a list of shows
    expect(list_of_shows).not_to be_empty
    expect(list_of_shows.length).to eq(3)

    first_show = list_of_shows[0]
    second_show = list_of_shows[1]

    # validate that (some of) the shows and orders are correct
    expect(first_show.name).to eq("show0")
    expect(second_show.name).to eq("show1")
    expect(second_show.values[:show_order]).to eq(1)

    # change the show order
    reordered_show_list = bot1_test.set_show_order(first_show, 2)

    # confirm that the new order is correct
    expect(reordered_show_list[0].name).to eq("show1")
    expect(reordered_show_list[0].values[:show_order]).to eq(0)
    expect(reordered_show_list[1].name).to eq("show2")
    expect(reordered_show_list[1].values[:show_order]).to eq(1)
    expect(reordered_show_list[2].name).to eq("show0")
    expect(reordered_show_list[2].values[:show_order]).to eq(2)

  end

  describe "#generate_schedule" do
    let(:user) { User.new(name: "test_user", config: { days: "m,t", time: "60" }.to_json) }
    let(:show1) { double('Show', name: "Show 1", average_runtime: 40) }
    let(:show2) { double('Show', name: "Show 2", average_runtime: 20) }
    let(:show3) { double('Show', name: "Show 3", average_runtime: 30) }

    before do
      allow(user).to receive(:shows).and_return([show1, show2, show3])
      allow(user).to receive(:save).and_return(true)
      # Mocking Show.find which is used in find_next_available_slot_for_schedule
      allow(Show).to receive(:find).with(name: "Show 1").and_return(show1)
      allow(Show).to receive(:find).with(name: "Show 2").and_return(show2)
      allow(Show).to receive(:find).with(name: "Show 3").and_return(show3)
    end

    it "packs shows into days based on order and availability" do
      schedule = user.generate_schedule
      
      expect(schedule["Monday"]).to contain_exactly("Show 1", "Show 2") # 40 + 20 = 60
      expect(schedule["Tuesday"]).to contain_exactly("Show 3")          # 30 < 60
    end
  end

  it "checks for day in schedule" do
    actual = bot1_test.is_show_in_schedule?("foo")
    expect(actual).to be_truthy
  end

  it "finds next available slot for bot user" do
    allow(bot1_test).to receive_message_chain(:shows_dataset,
                                              :where,
                                              :first).and_return(bot_shows[1])
    next_slot = bot1_test.find_next_available_slot("show1")
    expect(next_slot).to eq("Monday")
  end

  #it "checks if Tuesday is full in second seeded user's schedule" do
  #  sched = seed_test.generate_schedule
  #  p sched
  # actual = seed_test.get_available_runtime_for_day("Tuesday")
  #  expect(actual).to eq(32)
  #end

  #it "generates populated schedule from first seeded user", failing: true do
  #
  #  seed_just.generate_schedule()
  #  weekday = "Tuesday"
  #
  #  sched = JSON.parse(seed_just.schedule)
  #
  #  expect(sched).not_to be_nil
  #  expect(sched[weekday]).not_to be_empty
  #  expect(sched[weekday].length).to eq(2)
  #  expect(sched[weekday]).to include("Suits")

  #end

  #it "generates a second populated schedule" do

  #  seed_test.generate_schedule
  #  weekday = "Tuesday"

  #  sched = JSON.parse(seed_test.schedule)

  #  expect(sched[weekday]).not_to be_empty
  #  expect(sched[weekday][0]).to eq("His Dark Materials")

  # end

end
