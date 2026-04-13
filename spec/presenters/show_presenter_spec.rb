require 'spec_helper'
require 'presenters/show_presenter'

RSpec.describe Presenters::ShowPresenter do
  # We use a "double" instead of a real database model.
  # This makes the test fast and independent!
  let(:show) { double('Show', id: 1, name: 'Test Show', runtime: '30 mins', uri_encoded: 'test-show', poster_path: '/test.jpg') }
  let(:presenter) { Presenters::ShowPresenter.new(show) }

  it "formats the poster URL correctly" do
    expect(presenter.to_h[:poster_url]).to eq("https://image.tmdb.org/t/p/w500/test.jpg")
  end

  it "converts runtime to an integer" do
    expect(presenter.to_h[:runtime]).to eq(30)
  end
end
