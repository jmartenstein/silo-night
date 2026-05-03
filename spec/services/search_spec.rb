require 'spec_helper'
require 'services/search'

RSpec.describe Services::Search do
  describe '.search' do
    it 'returns a list of shows based on a query' do
      # We anticipate needing to stub adapters eventually
      results = described_class.search('The Expanse')
      
      expect(results).to be_an(Array)
      expect(results.first).to have_key('title')
    end
  end
end
