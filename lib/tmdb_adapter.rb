require_relative 'api_client'
require 'dotenv/load'

class TmdbAdapter
  BASE_URL = 'https://api.themoviedb.org/3'

  def initialize(api_key = ENV['TMDB_API_KEY'])
    @api_key = api_key
    @client = ApiClient.new(BASE_URL, {}, { 'api_key' => @api_key })
  end

  def fetch_show_by_id(tmdb_id)
    response = @client.get("tv/#{tmdb_id}")
    return nil unless response&.success?

    JSON.parse(response.body)
  end

  def search_shows_by_title(title)
    response = @client.get("search/tv", { query: title })
    return [] unless response&.success?

    JSON.parse(response.body)['results']
  end
end
