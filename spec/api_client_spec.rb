require 'spec_helper'
require 'api_client'

RSpec.describe ApiClient do
  let(:base_url) { 'https://api.example.com' }
  let(:client) { ApiClient.new(base_url) }

  describe '#get' do
    it 'returns successful response' do
      stub_request(:get, "#{base_url}/test")
        .to_return(status: 200, body: 'ok')

      response = client.get('test')
      expect(response.status).to eq(200)
      expect(response.body).to eq('ok')
    end

    it 'retries on 429' do
      # Need to allow sleep to be mocked to avoid slow tests
      allow(client).to receive(:sleep)

      stub_request(:get, "#{base_url}/rate-limited")
        .to_return(status: 429, headers: { 'Retry-After' => '1' }).then
        .to_return(status: 200, body: 'ok after retry')

      response = client.get('rate-limited')
      expect(response.status).to eq(200)
      expect(response.body).to eq('ok after retry')
      expect(client).to have_received(:sleep).with(1)
    end

    it 'retries on 500' do
      allow(client).to receive(:sleep)

      stub_request(:get, "#{base_url}/server-error")
        .to_return(status: 500).then
        .to_return(status: 200, body: 'ok after 500')

      response = client.get('server-error')
      expect(response.status).to eq(200)
      expect(response.body).to eq('ok after 500')
      expect(client).to have_received(:sleep).with(2) # First retry delay is 2^1 * RETRY_DELAY = 2
    end

    it 'gives up after max retries' do
      allow(client).to receive(:sleep)

      stub_request(:get, "#{base_url}/persistent-error")
        .to_return(status: 500)

      response = client.get('persistent-error')
      expect(response.status).to eq(500)
      expect(client).to have_received(:sleep).exactly(3).times
    end

    it 'gracefully handles connection errors' do
      allow(client).to receive(:sleep)

      stub_request(:get, "#{base_url}/conn-error")
        .to_raise(Faraday::ConnectionFailed.new('failed'))

      response = client.get('conn-error')
      expect(response).to be_nil
      expect(client).to have_received(:sleep).exactly(3).times
    end
  end
end
