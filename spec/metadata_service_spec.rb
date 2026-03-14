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
        'first_air_date' => '2008-01-20',
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
        'premiered' => '2008-01-20',
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
      expect(result[:year]).to eq(2008)
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
      expect(result[:year]).to eq(2008)
    end

    it 'returns nil if neither provider finds the show' do
      allow(tmdb_adapter).to receive(:search_shows_by_title).with(title).and_return([])
      allow(tvmaze_adapter).to receive(:search_shows_by_title).with(title).and_return([])
      result = service.get_show_metadata(title)
      expect(result).to be_nil
    end
  end

  describe '#search_shows' do
    let(:title) { 'Breaking Bad' }
    let(:tmdb_results) do
      [
        { 'id' => 1396, 'name' => 'Breaking Bad', 'first_air_date' => '2008-01-20', 'genre_ids' => [18], 'poster_path' => '/bb.jpg' }
      ]
    end
    let(:tvmaze_results) do
      [
        { 'id' => 169, 'name' => 'Breaking Bad', 'premiered' => '2008-01-20', 'genres' => ['Drama', 'Crime'], 'image' => { 'medium' => 'tvm_bb.jpg' } }
      ]
    end

    before do
      allow(tmdb_adapter).to receive(:search_shows_by_title).with(title).and_return(tmdb_results)
      allow(tvmaze_adapter).to receive(:search_shows_by_title).with(title).and_return(tvmaze_results)
    end

    it 'returns a list of suggestions with name, year, genres, and poster_path' do
      results = service.search_shows(title)
      expect(results).to be_an(Array)
      expect(results.first[:name]).to eq('Breaking Bad')
      expect(results.first[:year]).to eq(2008)
      expect(results.first[:genres]).to contain_exactly('Drama', 'Crime')
      expect(results.first[:poster_path]).to eq('tvm_bb.jpg')
    end

    it 'correctly formats TMDB poster path when TVMaze result is missing' do
      allow(tvmaze_adapter).to receive(:search_shows_by_title).with(title).and_return([])
      results = service.search_shows(title)
      expect(results.first[:poster_path]).to eq('https://image.tmdb.org/t/p/w500/bb.jpg')
    end
  end
end
