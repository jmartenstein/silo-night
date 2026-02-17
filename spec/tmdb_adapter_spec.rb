require 'spec_helper'
require 'tmdb_adapter'

RSpec.describe TmdbAdapter do
  let(:adapter) { TmdbAdapter.new('test_api_key') }

  describe '#fetch_show_by_id', :vcr do
    it 'returns show data for a valid TMDB ID' do
      # For VCR to record this, I'll need a real ID or just mock it.
      # Since I have dummy keys, I'll rely on VCR recorded cassettes if I had them,
      # but here I'll mock the response to ensure it works.
      
      stub_request(:get, "https://api.themoviedb.org/3/tv/1399?api_key=test_api_key")
        .to_return(status: 200, body: { id: 1399, name: 'Game of Thrones' }.to_json)

      result = adapter.fetch_show_by_id(1399)
      expect(result['id']).to eq(1399)
      expect(result['name']).to eq('Game of Thrones')
    end

    it 'returns nil for an invalid ID' do
      stub_request(:get, "https://api.themoviedb.org/3/tv/invalid?api_key=test_api_key")
        .to_return(status: 404, body: { status_message: 'The resource you requested could not be found.' }.to_json)

      result = adapter.fetch_show_by_id('invalid')
      expect(result).to be_nil
    end
  end

  describe '#search_shows_by_title', :vcr do
    it 'returns a list of shows matching the title' do
      stub_request(:get, "https://api.themoviedb.org/3/search/tv?api_key=test_api_key&query=Breaking%20Bad")
        .to_return(status: 200, body: { results: [{ id: 1396, name: 'Breaking Bad' }] }.to_json)

      result = adapter.search_shows_by_title('Breaking Bad')
      expect(result.first['name']).to eq('Breaking Bad')
    end
  end
end
