require 'spec_helper'
require 'tvmaze_adapter'

RSpec.describe TvmazeAdapter do
  let(:adapter) { TvmazeAdapter.new }

  describe '#fetch_show_by_id' do
    it 'returns show data for a valid TVMaze ID', vcr: { cassette_name: 'tvmaze/fetch_show_valid', record: :new_episodes } do
      result = adapter.fetch_show_by_id(81)
      expect(result['id']).to eq(81)
      expect(result['name']).to eq('Criminal Minds')
    end

    it 'returns nil for an invalid ID', vcr: { cassette_name: 'tvmaze/fetch_show_invalid', record: :new_episodes } do
      result = adapter.fetch_show_by_id('invalid')
      expect(result).to be_nil
    end
  end

  describe '#search_shows_by_title' do
    it 'returns a list of shows matching the title', vcr: { cassette_name: 'tvmaze/search_shows', record: :new_episodes } do
      result = adapter.search_shows_by_title('Breaking Bad')
      expect(result.first['name']).to eq('Breaking Bad')
    end
  end
end
