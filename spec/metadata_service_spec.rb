require 'spec_helper'
require 'metadata_service'

RSpec.describe MetadataService do
  let(:tmdb_adapter) { double('TmdbAdapter') }
  let(:tvmaze_adapter) { double('TvmazeAdapter') }
  let(:service) { MetadataService.new(tmdb_adapter, tvmaze_adapter) }

  describe '#get_show_metadata' do
    let(:title) { 'Breaking Bad' }
    let(:tmdb_search_results) { [{ 'id' => 1396 }] }
    let(:tmdb_show_details) do
      {
        'id' => 1396,
        'name' => 'Breaking Bad',
        'episode_run_time' => [45],
        'genres' => [{ 'name' => 'Drama' }],
        'poster_path' => '/poster.jpg',
        'overview' => 'Heisenberg is born.'
      }
    end
    let(:tvmaze_search_results) { [{ 'id' => 169 }] }
    let(:tvmaze_show_details) do
      {
        'id' => 169,
        'name' => 'Breaking Bad',
        'averageRuntime' => 45,
        'genres' => ['Drama', 'Crime'],
        'image' => { 'medium' => 'tvmaze_poster.jpg' },
        'summary' => '<p>Heisenberg is born.</p>'
      }
    end

    before do
      allow(tmdb_adapter).to receive(:search_shows_by_title).with(title).and_return(tmdb_search_results)
      allow(tmdb_adapter).to receive(:fetch_show_by_id).with(1396).and_return(tmdb_show_details)
      allow(tvmaze_adapter).to receive(:search_shows_by_title).with(title).and_return(tvmaze_search_results)
      allow(tvmaze_adapter).to receive(:fetch_show_by_id).with(169).and_return(tvmaze_show_details)
    end

    it 'returns unified metadata' do
      result = service.get_show_metadata(title)
      expect(result[:name]).to eq('Breaking Bad')
      expect(result[:runtime]).to eq('45 minutes')
      expect(result[:genres]).to contain_exactly('Drama', 'Crime')
      expect(result[:poster_path]).to eq('https://image.tmdb.org/t/p/w500/poster.jpg')
      expect(result[:overview]).to eq('Heisenberg is born.')
      expect(result[:external_ids][:tmdb_id]).to eq(1396)
      expect(result[:external_ids][:tvmaze_id]).to eq(169)
    end

    it 'falls back to TVMaze if TMDB search fails' do
      allow(tmdb_adapter).to receive(:search_shows_by_title).with(title).and_return([])
      result = service.get_show_metadata(title)
      expect(result[:name]).to eq('Breaking Bad')
      expect(result[:poster_path]).to eq('tvmaze_poster.jpg')
    end

    it 'returns nil if neither provider finds the show' do
      allow(tmdb_adapter).to receive(:search_shows_by_title).with(title).and_return([])
      allow(tvmaze_adapter).to receive(:search_shows_by_title).with(title).and_return([])
      result = service.get_show_metadata(title)
      expect(result).to be_nil
    end
  end
end
