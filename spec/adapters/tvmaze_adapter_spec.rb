require 'spec_helper'
require 'tvmaze_adapter'

RSpec.describe TvmazeAdapter do
  let(:adapter) { TvmazeAdapter.new('test_api_key') }

  describe '#fetch_show_by_id' do
    it 'returns show data for a valid TVMaze ID' do
      stub_request(:get, "https://api.tvmaze.com/shows/81")
        .to_return(status: 200, body: { id: 81, name: 'Game of Thrones' }.to_json)

      result = adapter.fetch_show_by_id(81)
      expect(result['id']).to eq(81)
      expect(result['name']).to eq('Game of Thrones')
    end

    it 'returns nil for an invalid ID' do
      stub_request(:get, "https://api.tvmaze.com/shows/invalid")
        .to_return(status: 404, body: { status_message: 'The resource you requested could not be found.' }.to_json)

      result = adapter.fetch_show_by_id('invalid')
      expect(result).to be_nil
    end
  end

  describe '#search_shows_by_title' do
    it 'returns a list of shows matching the title' do
      stub_request(:get, "https://api.tvmaze.com/search/shows?q=Breaking%20Bad")
        .to_return(status: 200, body: [{ score: 0.99, show: { id: 169, name: 'Breaking Bad' } }].to_json)

      result = adapter.search_shows_by_title('Breaking Bad')
      expect(result.first['name']).to eq('Breaking Bad')
    end
  end
end
