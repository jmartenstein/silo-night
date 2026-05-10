require 'spec_helper'
require 'metadata_service'

RSpec.describe MetadataService do
  let(:tmdb_adapter) { instance_double(TmdbAdapter) }
  let(:tvmaze_adapter) { instance_double(TvmazeAdapter) }
  let(:service) { MetadataService.new(tmdb_adapter, tvmaze_adapter) }

  before do
    # Ensure local database lookup doesn't interfere
    dataset = double('Dataset')
    allow(dataset).to receive(:limit).and_return([])
    allow(Show).to receive(:where).and_return(dataset)
  end

  it 'filters out TMDB shows with popularity <= 5.0 and TVMaze shows with weight <= 30' do
    tmdb_results = [
      { 'name' => 'Popular Show', 'popularity' => 10.0, 'first_air_date' => '2020-01-01' },
      { 'name' => 'Obscure Show', 'popularity' => 2.0, 'first_air_date' => '2020-01-01' }
    ]
    tvmaze_results = [
      { 'name' => 'Popular TVMaze', 'weight' => 50, 'premiered' => '2020-01-01' },
      { 'name' => 'Obscure TVMaze', 'weight' => 10, 'premiered' => '2020-01-01' }
    ]

    allow(tmdb_adapter).to receive(:search_shows_by_title).with('The Show').and_return(tmdb_results)
    allow(tvmaze_adapter).to receive(:search_shows_by_title).with('The Show').and_return(tvmaze_results)

    results = service.search_shows('The Show')
    
    names = results.map { |r| r[:name] }
    expect(names).to include('Popular Show')
    expect(names).to include('Popular TVMaze')
    expect(names).not_to include('Obscure Show')
    expect(names).not_to include('Obscure TVMaze')
  end

  it 'respects strict boundary conditions' do
    tmdb_results = [
      { 'name' => 'Boundary Out', 'popularity' => 5.0 },
      { 'name' => 'Boundary In', 'popularity' => 5.01 }
    ]
    tvmaze_results = [
      { 'name' => 'Boundary Out', 'weight' => 30 },
      { 'name' => 'Boundary In', 'weight' => 31 }
    ]

    allow(tmdb_adapter).to receive(:search_shows_by_title).with('Boundary').and_return(tmdb_results)
    allow(tvmaze_adapter).to receive(:search_shows_by_title).with('Boundary').and_return(tvmaze_results)

    results = service.search_shows('Boundary')
    names = results.map { |r| r[:name] }
    expect(names).to include('Boundary In')
    expect(names).not_to include('Boundary Out')
  end

  it 'handles missing popularity or weight fields by filtering them out' do
    tmdb_results = [{ 'name' => 'No Popularity', 'first_air_date' => '2020-01-01' }]
    tvmaze_results = [{ 'name' => 'No Weight', 'premiered' => '2020-01-01' }]

    allow(tmdb_adapter).to receive(:search_shows_by_title).with('Test').and_return(tmdb_results)
    allow(tvmaze_adapter).to receive(:search_shows_by_title).with('Test').and_return(tvmaze_results)

    results = service.search_shows('Test')
    expect(results).to be_empty
  end

  it 'handles empty result arrays gracefully' do
    allow(tmdb_adapter).to receive(:search_shows_by_title).with('Empty').and_return([])
    allow(tvmaze_adapter).to receive(:search_shows_by_title).with('Empty').and_return([])

    expect { service.search_shows('Empty') }.not_to raise_error
  end
end
