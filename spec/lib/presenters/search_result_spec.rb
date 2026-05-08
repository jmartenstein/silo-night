require 'spec_helper'
require 'presenters/search_result'

RSpec.describe Presenters::SearchResult do
  let(:search_results) { [{ name: 'The Expanse' }, { name: 'Foundation' }] }
  let(:presenter) { described_class.new(search_results) }

  
  it 'formats search results into a standardized JSON array' do
    result = presenter.to_h
    expect(result).to be_an(Array)
    expect(result.first).to eq({
      'name' => 'The Expanse',
      'year' => nil,
      'genres' => nil,
      'poster_path' => nil
    })
  end
end
