require 'spec_helper'
require 'presenters/show'

RSpec.describe Presenters::Show do
  # Update the double to test both cases: relative path and full URL
  let(:show_rel) { instance_double('Show', id: 1, name: 'Rel Show', runtime: '30 mins', uri_encoded: 'rel-show', poster_path: '/test.jpg') }
  let(:show_full) { instance_double('Show', id: 2, name: 'Full Show', runtime: '60 mins', uri_encoded: 'full-show', poster_path: 'https://example.com/poster.jpg') }

  it "prefixes relative poster paths" do
    presenter = Presenters::Show.new(show_rel)
    expect(presenter.to_h[:poster_url]).to eq("https://image.tmdb.org/t/p/w500/test.jpg")
  end

  it "passes through full poster URLs" do
    presenter = Presenters::Show.new(show_full)
    expect(presenter.to_h[:poster_url]).to eq("https://example.com/poster.jpg")
  end

  it "converts runtime to an integer" do
    presenter = Presenters::Show.new(show_rel)
    expect(presenter.to_h[:runtime]).to eq(30)
  end
end
