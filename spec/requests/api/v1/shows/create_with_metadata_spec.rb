# spec/requests/api/v1/shows/create_with_metadata_spec.rb
#
# API contract tests for issue #84:
# POST /api/v1/user/:name/shows — optional metadata passthrough
#
# When the client sends pre-fetched metadata in the request body the server
# must use it directly and must NOT make external calls to TMDB or TVMaze.
# When metadata is absent the existing MetadataService fallback must be
# preserved (backwards compatibility).

require 'spec_helper'

RSpec.describe 'API v1 Shows Create with Metadata', type: :integration do
  before { create(:user, name: 'leonard') }

  let(:json_headers) { { 'CONTENT_TYPE' => 'application/json' } }

  # ---------------------------------------------------------------------------
  # Contract: response shape is unchanged regardless of whether metadata was
  # supplied by the client or fetched server-side.
  # ---------------------------------------------------------------------------
  describe 'response contract' do
    it 'returns 201 and a show object conforming to the show schema when metadata is provided' do
      body = {
        name: 'The Bear',
        year: 2022,
        genres: ['Drama', 'Comedy'],
        poster_path: 'https://image.tmdb.org/t/p/w500/poster.jpg',
        external_ids: { tmdb_id: 136_315, tvmaze_id: 56_294 }
      }.to_json

      post '/api/v1/user/leonard/shows', body, json_headers

      expect(last_response.status).to eq(201)
      validate_contract('show_schema', JSON.parse(last_response.body))
    end
  end

  # ---------------------------------------------------------------------------
  # Contract: when metadata IS supplied the show is persisted without any
  # outbound HTTP requests to TMDB or TVMaze.
  # ---------------------------------------------------------------------------
  describe 'no external HTTP calls when metadata is provided' do
    it 'creates the show using only the supplied metadata — no network requests' do
      # WebMock (loaded via spec_helper / webmock/rspec) blocks all real HTTP
      # by default in the test environment. If the server tries to call TMDB
      # or TVMaze this example will raise WebMock::NetConnectNotAllowedError
      # and fail — proving the shortcut path is taken.
      body = {
        name: 'Severance',
        year: 2022,
        genres: ['Sci-Fi & Fantasy', 'Drama'],
        poster_path: 'https://image.tmdb.org/t/p/w500/sev_poster.jpg',
        external_ids: { tmdb_id: 97_778, tvmaze_id: 44_217 }
      }.to_json

      expect {
        post '/api/v1/user/leonard/shows', body, json_headers
      }.not_to raise_error

      expect(last_response.status).to eq(201)
    end

    it 'persists the show with the supplied metadata payload' do
      body = {
        name: 'Severance',
        year: 2022,
        genres: ['Sci-Fi & Fantasy'],
        poster_path: 'https://image.tmdb.org/t/p/w500/sev_poster.jpg',
        runtime: '60 minutes',
        external_ids: { tmdb_id: 97_778, tvmaze_id: 44_217 }
      }.to_json

      post '/api/v1/user/leonard/shows', body, json_headers

      show = Show.find(name: 'Severance')
      expect(show).not_to be_nil
      expect(show.metadata).not_to be_nil
      expect(show.metadata.payload['name']).to eq('Severance')
      expect(show.metadata.payload['genres']).to include('Sci-Fi & Fantasy')
      expect(show.metadata.payload['poster_path']).to eq('https://image.tmdb.org/t/p/w500/sev_poster.jpg')
      expect(show.metadata.payload['runtime']).to eq('60 minutes')
    end

    it 'stores the external IDs in the metadata payload' do
      body = {
        name: 'Severance',
        year: 2022,
        genres: [],
        poster_path: nil,
        external_ids: { tmdb_id: 97_778, tvmaze_id: 44_217 }
      }.to_json

      post '/api/v1/user/leonard/shows', body, json_headers

      show = Show.find(name: 'Severance')
      external_ids = show.metadata.payload.dig('external_ids')
      expect(external_ids['tmdb_id']).to eq(97_778)
      expect(external_ids['tvmaze_id']).to eq(44_217)
    end

    it 'stores the provider_name as "client" to distinguish from server-fetched metadata' do
      body = {
        name: 'Severance',
        year: 2022,
        genres: [],
        poster_path: nil,
        external_ids: { tmdb_id: 97_778, tvmaze_id: 44_217 }
      }.to_json

      post '/api/v1/user/leonard/shows', body, json_headers

      show = Show.find(name: 'Severance')
      expect(show.metadata.provider_name).to eq('client')
    end
  end

  # ---------------------------------------------------------------------------
  # Contract: partial metadata — only some optional fields present. The server
  # must still accept the request and not crash.
  # ---------------------------------------------------------------------------
  describe 'partial metadata in request body' do
    it 'accepts a body with only name and external_ids (no genres, no poster)' do
      body = {
        name: 'Slow Horses',
        external_ids: { tmdb_id: 101_484, tvmaze_id: nil }
      }.to_json

      post '/api/v1/user/leonard/shows', body, json_headers

      expect(last_response.status).to eq(201)
      show = Show.find(name: 'Slow Horses')
      expect(show).not_to be_nil
    end
  end

  # ---------------------------------------------------------------------------
  # Contract: backwards compatibility — body with only `name` (no metadata)
  # must still work exactly as before. We use a pre-existing show in the DB so
  # no MetadataService call is needed and WebMock stays happy.
  # ---------------------------------------------------------------------------
  describe 'backwards compatibility — name-only body' do
    before do
      create(:show, :with_metadata, name: 'Foundation', runtime: '60')
    end

    it 'adds an existing show to the user without metadata in the body' do
      post '/api/v1/user/leonard/shows',
           { name: 'Foundation' }.to_json,
           json_headers

      expect(last_response.status).to eq(201)
      expect(User.find(name: 'leonard').shows).to include(Show.find(name: 'Foundation'))
    end
  end

  # ---------------------------------------------------------------------------
  # Contract: duplicate show names — adding a show with the same name as an
  # existing show but different external IDs should create a new show with
  # the year appended (e.g. "Silo (2023)").
  # ---------------------------------------------------------------------------
  describe 'duplicate show names' do
    before do
      # Create an existing show "Silo" (2017)
      show_2017 = create(:show, name: 'Silo')
      create(:show_metadata,
             provider_name: 'tmdb',
             external_id: '71485', # Silo 2017 TMDB ID
             payload: { 'name' => 'Silo', 'year' => 2017, 'external_ids' => { 'tmdb_id' => 71485 } },
             show: show_2017)
    end

    it 'creates a new show with the year appended when the external IDs differ' do
      body = {
        name: 'Silo',
        year: 2023,
        external_ids: { tmdb_id: 125988 } # Silo 2023 TMDB ID
      }.to_json

      post '/api/v1/user/leonard/shows', body, json_headers

      expect(last_response.status).to eq(201)
      
      # Verify the new show was created with the year appended
      show_2023 = Show.find(name: 'Silo (2023)')
      expect(show_2023).not_to be_nil
      expect(show_2023.metadata.payload['external_ids']['tmdb_id']).to eq(125988)

      # Verify the old show still exists untouched
      show_2017 = Show.find(name: 'Silo')
      expect(show_2017).not_to be_nil
      expect(show_2017.metadata.payload['external_ids']['tmdb_id']).to eq(71485)
    end

    it 'reuses the existing show when the external IDs match' do
      body = {
        name: 'Silo',
        year: 2017,
        external_ids: { tmdb_id: 71485 }
      }.to_json

      post '/api/v1/user/leonard/shows', body, json_headers

      expect(last_response.status).to eq(201)
      
      # Should not create a new show
      expect(Show.where(name: 'Silo').count).to eq(1)
      expect(Show.where(name: 'Silo (2017)').count).to eq(0)
    end
  end
end
