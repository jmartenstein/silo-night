require 'spec_helper'
require 'services/search'

RSpec.describe 'Local-First Search Strategy' do
  it 'includes shows from the database in the search results', vcr: { record: :once } do
    # 1. Seed the database with a show
    Show.create(name: 'The Expanse', poster_path: '/poster.jpg')

    # 2. Perform search
    results = Services::Search.search('The Expanse')

    # 3. Assertions
    expect(results).to be_an(Array)
    expect(results.any? { |s| s[:name] == 'The Expanse' }).to be true
    
    # 4. Assert deduplication: The Expanse should only appear once
    expanse_results = results.select { |s| s[:name] == 'The Expanse' }
    expect(expanse_results.size).to eq(1)
  end
end
