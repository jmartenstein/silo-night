require 'spec_helper'
require 'presenters/schedule'
require 'show'
require 'presenters/show'

RSpec.describe Presenters::Schedule do
  let!(:show) { Show.create(name: 'The Expanse', runtime: '60', poster_path: '/path.jpg') }
  let(:raw_schedule) do
    { 'Monday' => [{ 'name' => show.name }] }
  end
  let(:presenter) { described_class.new(raw_schedule) }

  describe '#to_h' do
    it 'returns a normalized 7-day schedule' do
      expect(presenter.to_h.keys.size).to eq(7)
    end

    it 'integrates with Presenters::Show to provide rich show data' do
      monday_shows = presenter.to_h['Monday']
      expect(monday_shows.first).to have_key(:poster_url)
      expect(monday_shows.first[:poster_url]).to include('tmdb.org')
    end
  end
end
