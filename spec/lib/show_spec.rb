require 'show'
require 'rspec'

describe Show do

  it "creates a new show with an empty name" do
    n = Show.new
    expect(n.values).to be_empty
  end

  it "loads name from a data structure" do
    s = Show.new(name: "Suits")
    expect(s.name).to eq("Suits")
  end

  it "calculates an average from one number via metadata" do
    s = create(:show, :with_metadata, runtime: "42 minutes")
    expect(s.average_runtime).to eq(42)
  end

  it "calculates an average from two numbers via metadata" do
    s = create(:show, :with_metadata, runtime: "28-32 minutes")
    expect(s.average_runtime).to eq(30)
  end

  context "with metadata" do
    let(:show) { create(:show) }
    let(:metadata) { create(:show_metadata, payload: { "runtime" => "60 minutes", "poster_path" => "/path/to/poster.jpg" }, show: show) }

    it "retrieves runtime from metadata if present" do
      show.metadata = metadata
      expect(show.runtime).to eq("60 minutes")
    end

    it "retrieves poster_path from metadata if present" do
      show.metadata = metadata
      expect(show.poster_path).to eq("/path/to/poster.jpg")
    end

    it "falls back to columns if metadata values are missing" do
      # We manually inject into @values to simulate the legacy column state
      # without relying on the now-restricted mass-assignment setter.
      s = Show.new
      s.values[:runtime] = "30 minutes"
      
      # Associated metadata exists but is empty
      s.metadata = create(:show_metadata, payload: {}, show: s)
      
      expect(s.runtime).to eq("30 minutes")
    end
  end

end

describe Shows do

  let(:shows)    { '[ { "name": "foo", "runtime": "12 minutes", "poster_path": "foo.jpg" } ]' }
  let(:filename) { "spec/support/shows.json" }

  it "initializes an empty list" do
    l = Shows.new()
    expect(l.count).to eq(0)
  end

  it "list loads from a file" do
    l = Shows.new()
    l.load_from_file(filename)
    expect(l[0].name).to eq("foo")
  end

  it "list loads from json" do
    l = Shows.new()
    l.load_from_json(shows)
    expect(l[0].runtime).to eq("12 minutes")
    expect(l[0].poster_path).to eq("foo.jpg")
  end

end

