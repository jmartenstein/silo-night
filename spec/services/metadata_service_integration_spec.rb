require 'spec_helper'
require 'metadata_service'
require 'tmdb_adapter'
require 'tvmaze_adapter'

RSpec.describe MetadataService, type: :integration do
  let(:service) { MetadataService.new(TmdbAdapter.new, TvmazeAdapter.new) }
  
  it 'successfully fetches and merges data', vcr: { cassette_name: 'metadata_service/happy_path' } do
    result = service.get_show_metadata('Breaking Bad')
    expect(result[:name]).to eq('Breaking Bad')
  end
end
