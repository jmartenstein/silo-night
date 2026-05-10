require 'spec_helper'
require 'metadata_service'

RSpec.describe MetadataService do
  let(:service) { MetadataService.new }

  it 'filters out TMDB shows with popularity <= 5.0 and TVMaze shows with weight <= 30' do
    # We will need to mock the adapters to control the input
    tmdb_adapter = instance_double(TmdbAdapter)
    tvmaze_adapter = instance_double(TvmazeAdapter)
    service = MetadataService.new(tmdb_adapter, tvmaze_adapter)

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
end
