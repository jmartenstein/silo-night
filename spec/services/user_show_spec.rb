require 'spec_helper'
require 'services/user_show'

RSpec.describe Services::UserShow do
  let(:user) { double('User', add_show: true, generate_schedule: true, shows: [], reload: true) }
  let(:show) { double('Show') }

  describe ".add_show" do
    it "adds the show to the user and regenerates the schedule" do
      expect(user).to receive(:add_show).with(show)
      expect(user).to receive(:generate_schedule)
      
      Services::UserShow.add_show(user, show)
    end
  end
end
