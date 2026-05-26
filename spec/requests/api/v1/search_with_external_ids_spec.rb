# spec/requests/api/v1/search_with_external_ids_spec.rb
#
# API contract tests for issue #84:
# GET /api/v1/search — response must include external_ids so the client can
# pass them back in the subsequent POST /shows request.

require 'spec_helper'

RSpec.describe 'API v1 Search includes external_ids', type: :integration do

  let(:json_headers) { { 'CONTENT_TYPE' => 'application/json' } }

  # ---------------------------------------------------------------------------
  # Contract: each search result must include an `external_ids` object with
  # at minimum the keys `tmdb_id` and `tvmaze_id`.
  # ---------------------------------------------------------------------------
  describe 'GET /api/v1/search' do
    it 'returns external_ids in each result when searching for a show', vcr: { record: :new_episodes } do
      get '/api/v1/search', { q: 'The Expanse' }

      expect(last_response.status).to eq(200)
      json = JSON.parse(last_response.body)
      expect(json).to be_an(Array)
      expect(json).not_to be_empty

      result = json.first
      expect(result).to have_key('external_ids')
      expect(result['external_ids']).to have_key('tmdb_id')
      expect(result['external_ids']).to have_key('tvmaze_id')
    end
  end
end
