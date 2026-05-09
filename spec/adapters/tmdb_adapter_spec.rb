require 'spec_helper'
require 'tmdb_adapter'

RSpec.describe TmdbAdapter do
  let(:adapter) { TmdbAdapter.new(ENV['TMDB_API_KEY']) }

  describe '#fetch_show_by_id' do
    it 'returns show data for a valid TMDB ID', vcr: { cassette_name: 'tmdb/fetch_show_valid', record: :new_episodes } do
      result = adapter.fetch_show_by_id(1399)
      expect(result).not_to be_nil
      expect(result['name']).to eq('Game of Thrones')
    end

    it 'returns nil for an invalid ID', vcr: { cassette_name: 'tmdb/fetch_show_invalid', record: :new_episodes } do
      result = adapter.fetch_show_by_id('invalid')
      expect(result).to be_nil
    end
  end

  describe '#search_shows_by_title' do
    it 'returns a list of shows matching the title', vcr: { cassette_name: 'tmdb/search_shows', record: :new_episodes } do
      result = adapter.search_shows_by_title('Breaking Bad')
      expect(result.first['name']).to eq('Breaking Bad')
    end
  end
end
