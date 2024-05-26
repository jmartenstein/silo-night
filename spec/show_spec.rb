require 'show'
require 'rspec'

describe Show do

  let(:suits)    {{ "name" => "Suits",    "runtime" => "42 minutes"    }}
  let(:platonic) {{ "name" => "Platonic", "runtime" => "28-32 minutes" }}

  it "creates a new show with an empty name" do
    n = Show.new
    expect(n.values).to be_empty
  end

  it "loads from a data structure" do
    s = Show.new(suits)
    expect(s.name).to eq(suits["name"])
  end

  it "calculates an average from one number" do
    s = Show.new(suits)
    expect(s.average_runtime).to eq(42)
  end

  it "calculates an average from two numbers" do
    s = Show.new(platonic)
    expect(s.average_runtime).to eq(30)
  end

  it "gets average from second line in seed data" do
    s = Show[2]
    expect(s.average_runtime).to eq(48)
  end

end

describe Shows do

  let(:shows)    { '[ { "name": "foo", "runtime": "12 minutes" } ]' }
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
  end

end

