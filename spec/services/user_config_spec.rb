require 'spec_helper'
require 'services/user_config'
require 'user'

RSpec.describe Services::UserConfig do
  let(:user) { User.create(name: 'steph', config: {}.to_json) }

  describe '.update_for_user' do
    it 'updates the user configuration with provided parameters' do
      params = { 'days' => 'm,t', 'time' => '60' }
      result = described_class.update_for_user(user, params)
      
      expect(result).to be true
      user.reload
      config = JSON.parse(user.config)
      expect(config['days']).to eq('m,t')
      expect(config['time']).to eq('60')
    end
  end

  describe '.get_for_user' do
    it 'retrieves the parsed configuration for the user' do
      user.update(config: { 'days' => 'w' }.to_json)
      config = described_class.get_for_user(user)
      expect(config['days']).to eq('w')
    end
  end
end
