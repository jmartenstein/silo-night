require 'user'
require 'spec_helper'
require 'services/show_factory'

describe User do
  # Shared data for both unit and integration tests
  let(:user) { create :user, name: "steph", config: { "days" => "t,w,th,f", "time" => "85" }.to_json }

  describe "Logic (Unit Tests)", type: :unit do
    it "checks for day in schedule" do
      user.update(schedule: { "Tuesday" => ["foo"] }.to_json)
      expect(user.is_show_in_schedule?("foo")).to be_truthy
      expect(user.is_show_in_schedule?("bar")).to be_falsey
    end

    it "calculates available runtime for day" do
      # Note: This test still touches DB because User logic currently relies on Sequel lookups.
      # However, we're categorizing it as unit because it tests a specific internal calculation.
      s1 = create(:show, name: "Show A", runtime: "30")
      s2 = create(:show, name: "Show B", runtime: "20")
      
      sched = { "Tuesday" => ["Show A", "Show B"] }
      user.update(schedule: sched.to_json)
      
      # 85 - (30 + 20) = 35
      expect(user.get_available_runtime_for_day("Tuesday")).to eq(35)
    end

    it "lookups full day name from abbreviation" do
      expect(user.config_day_lookup("m")).to eq("Monday")
      expect(user.config_day_lookup("th")).to eq("Thursday")
    end

    it "converts day name to abbreviation" do
      expect(user.day_to_abbr("Monday")).to eq("m")
      expect(user.day_to_abbr("Thursday")).to eq("th")
    end
  end

  describe "Persistence and Services (Integration Tests)", type: :integration, vcr: true do
    # Use ShowFactory to get "real" metadata (recorded via VCR)
    let(:show1) { Services::ShowFactory.create_with_metadata("The Equalizer") }
    let(:show2) { Services::ShowFactory.create_with_metadata("The Afterparty") }
    let(:show3) { Services::ShowFactory.create_with_metadata("His Dark Materials") }

    it "loads a schedule from an existing file" do
      user.load_from_file("./data/test.json")
      sched = JSON.parse(user.values[:schedule])
      expect(sched["Tuesday"]).to be_a(Array)
    end

    it "modifies the show order and persists to the database" do
      Services::UserShow.add_show(user, show1)
      Services::UserShow.add_show(user, show2)
      Services::UserShow.add_show(user, show3)
      
      list_of_shows = user.reload.shows
      expect(list_of_shows.length).to eq(3)

      # change the show order - move first_show to the end (index 2)
      user.set_show_order(list_of_shows[0], 2)

      # CRITICAL: Re-fetch from DB to ensure it was PERSISTED
      final_list = User.find(id: user.id).shows
      expect(final_list.map(&:name)).to eq([list_of_shows[1].name, list_of_shows[2].name, list_of_shows[0].name])
    end

    it "finds next available slot based on existing schedule" do
      user.update(config: { "days" => "m,t,w", "time" => "60" }.to_json)
      next_slot = user.find_next_available_slot(show2)
      expect(next_slot).to eq("Monday")
    end

    it "generates populated schedule with metadata poster paths" do
      user.update(config: { "days" => "t", "time" => "100" }.to_json)
      Services::UserShow.add_show(user, show3)
      
      user.generate_schedule
      sched = JSON.parse(user.schedule)

      expect(sched["Tuesday"]).not_to be_empty
      expect(sched["Tuesday"].first['name']).to eq("His Dark Materials")
      expect(sched["Tuesday"].first['poster_path']).to include("https://image.tmdb.org/t/p/w500")
    end

    it "re-generates schedule when show order changes" do
      u = create(:user, config: { "days" => "m", "time" => "100" }.to_json)
      s1 = create(:show, :with_metadata, name: "Show 1", runtime: "30")
      s2 = create(:show, :with_metadata, name: "Show 2", runtime: "30")
      
      Services::UserShow.add_show(u, s1)
      Services::UserShow.add_show(u, s2)
      
      u.generate_schedule
      expect(JSON.parse(u.schedule)["Monday"].first["name"]).to eq("Show 1")
      
      # Reorder
      DB[:shows_users].where(user_id: u.id, show_id: s1.id).update(show_order: 1)
      DB[:shows_users].where(user_id: u.id, show_id: s2.id).update(show_order: 0)
      u.refresh
      
      u.generate_schedule
      expect(JSON.parse(u.schedule)["Monday"].first["name"]).to eq("Show 2")
    end
  end
end
