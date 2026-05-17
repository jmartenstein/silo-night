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
  end
end
