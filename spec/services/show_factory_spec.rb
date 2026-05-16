require 'spec_helper'
require 'services/show_factory'

RSpec.describe Services::ShowFactory, type: :unit do
  describe '.create_with_metadata' do
    it 'creates a show and its associated metadata', :vcr do
      show = Services::ShowFactory.create_with_metadata('Slow Horses')
      
      expect(show).not_to be_nil
      expect(show.name).to eq('Slow Horses')
      expect(show.metadata).not_to be_nil
      expect(show.metadata.payload['name']).to eq('Slow Horses')
      expect(show.metadata.show_id).to eq(show.id)
    end

    it 'returns nil if metadata cannot be found' do
      # Mock MetadataService to return nil
      allow_any_instance_of(MetadataService).to receive(:get_show_metadata).and_return(nil)
      
      show = Services::ShowFactory.create_with_metadata('Nonexistent Show')
      expect(show).to be_nil
    end
  end
end
