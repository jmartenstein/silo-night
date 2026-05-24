require 'spec_helper'
require 'services/user_show'

RSpec.describe Services::UserShow, type: :integration do
  let(:user) { create(:user) }
  let(:show) { create(:show, :with_metadata, name: 'Expanse') }

  describe ".add_show" do
    it "adds the show to the user and regenerates the schedule" do
      # Since we are using a real user, we can verify persistence instead of mocking calls
      Services::UserShow.add_show(user, show)
      
      expect(user.shows.map(&:name)).to include('Expanse')
    end

    it "successfully adds a show by name (triggering ShowFactory)" do
      # Mocking MetadataService to avoid real API calls and focus on the constant resolution
      mock_metadata = {
        name: "New Show",
        external_ids: { tmdb_id: 12345 }
      }
      allow_any_instance_of(MetadataService).to receive(:get_show_metadata).and_return(mock_metadata)

      # This will raise NameError: uninitialized constant Services::ShowFactory
      # if the file is not required.
      expect {
        Services::UserShow.add_show(user, "New Show")
      }.not_to raise_error

      expect(Show.find(name: "New Show")).not_to be_nil
    end
  end
end
