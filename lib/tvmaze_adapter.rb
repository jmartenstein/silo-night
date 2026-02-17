require_relative 'api_client'
require 'dotenv/load'

class TvmazeAdapter
  BASE_URL = 'https://api.tvmaze.com'

  def initialize(api_key = ENV['TVMAZE_API_KEY'])
    @api_key = api_key
    headers = @api_key ? { 'X-TVMaze-Key' => @api_key } : {}
    @client = ApiClient.new(BASE_URL, headers)
  end

  def fetch_show_by_id(tvmaze_id)
    response = @client.get("shows/#{tvmaze_id}")
    return nil unless response&.success?

    JSON.parse(response.body)
  end

  def search_shows_by_title(title)
    response = @client.get("search/shows", { q: title })
    return [] unless response&.success?

    # TVMaze search results wrap each show in a 'show' object
    JSON.parse(response.body).map { |res| res['show'] }
  end
end
