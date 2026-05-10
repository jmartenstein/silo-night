require 'spec_helper'
require 'services/search'

RSpec.describe 'Local-First Search Strategy', type: :integration do
  it 'includes shows from the database in the search results', vcr: { record: :once } do
    Show.create(name: 'The Expanse', poster_path: '/poster.jpg')

    results = Services::Search.search('The Expanse')

    expect(results.any? { |s| s[:name] == 'The Expanse' }).to be true
    expanse_results = results.select { |s| s[:name] == 'The Expanse' }
    expect(expanse_results.size).to eq(1)
  end

  it 'handles case-insensitive and partial matches from the local database' do
    Show.create(name: 'The Expanse', poster_path: '/poster.jpg')
    
    # Stub adapters to avoid API calls
    allow_any_instance_of(TmdbAdapter).to receive(:search_shows_by_title).and_return([])
    allow_any_instance_of(TvmazeAdapter).to receive(:search_shows_by_title).and_return([])

    # Partial, lowercase query
    results = Services::Search.search('expanse')

    expect(results.any? { |s| s[:name] == 'The Expanse' }).to be true
  end

  it 'returns both local and API results when they are distinct shows' do
    # Local show
    Show.create(name: 'The Show', poster_path: '/local.jpg')
    
    # Stub API to return a different show
    allow_any_instance_of(TmdbAdapter).to receive(:search_shows_by_title).and_return([{'name' => 'Different Show', 'first_air_date' => '2020-01-01', 'popularity' => 10.0}])
    allow_any_instance_of(TvmazeAdapter).to receive(:search_shows_by_title).and_return([])

    results = Services::Search.search('The Show')

    # Both should be present
    names = results.map { |s| s[:name] }
    expect(names).to include('The Show', 'Different Show')
  end
end
