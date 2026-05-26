# spec/requests/api/v1/shows/runtime_minutes_hypothesis_spec.rb
require 'spec_helper'
require 'presenters/show'

RSpec.describe 'Runtime Minutes Hypothesis', type: :integration do
  before { create(:user, name: 'leonard') }

  let(:json_headers) { { 'CONTENT_TYPE' => 'application/json' } }

  it 'confirms that omitting runtime in the client metadata POST results in a presented runtime of 0' do
    # 1. Post a new show with metadata but without specifying runtime (as javascript does currently)
    body = {
      name: 'Show Without Runtime Specifying',
      year: 2024,
      genres: ['Sci-Fi'],
      poster_path: 'https://image.tmdb.org/t/p/w500/poster.jpg',
      external_ids: { tmdb_id: 12345, tvmaze_id: 67890 }
    }.to_json

    post '/api/v1/user/leonard/shows', body, json_headers
    expect(last_response.status).to eq(201)

    # 2. Get the user's shows list
    get '/api/v1/user/leonard/shows'
    expect(last_response.status).to eq(200)

    shows = JSON.parse(last_response.body)
    new_show = shows.find { |s| s['name'] == 'Show Without Runtime Specifying' }

    expect(new_show).not_to be_nil
    # This confirms the hypothesis: runtime is returned as 0
    expect(new_show['runtime']).to eq(0)
  end
end
