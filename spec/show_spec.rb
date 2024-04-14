require 'show'
require 'rspec'

describe Show do

  let(:suits) {{ "name" => "Suits", "runtime" => "42 minutes" }}
  let(:platonic) {{ "name" => "Platonic", "runtime" => "28-32 minutes" }}

  it "creates a new show with an empty name" do
    n = Show.new.name
    expect(n).to eq("")
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

end

