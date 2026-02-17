require_relative 'tmdb_adapter'
require_relative 'tvmaze_adapter'

class MetadataService
  def initialize(tmdb_adapter = TmdbAdapter.new, tvmaze_adapter = TvmazeAdapter.new)
    @tmdb_adapter = tmdb_adapter
    @tvmaze_adapter = tvmaze_adapter
  end

  def get_show_metadata(title)
    # 1. Search in TMDB first (usually has better poster and detailed info)
    tmdb_results = @tmdb_adapter.search_shows_by_title(title)
    tmdb_show = tmdb_results.any? ? @tmdb_adapter.fetch_show_by_id(tmdb_results.first['id']) : nil

    # 2. Search in TVMaze (good for runtimes and airing info)
    tvmaze_results = @tvmaze_adapter.search_shows_by_title(title)
    tvmaze_show = tvmaze_results.any? ? @tvmaze_adapter.fetch_show_by_id(tvmaze_results.first['id']) : nil

    return nil if tmdb_show.nil? && tvmaze_show.nil?

    # 3. Merge and unify
    unify_metadata(tmdb_show, tvmaze_show)
  end

  private

  def unify_metadata(tmdb_data, tvmaze_data)
    genres = []
    genres += tmdb_data['genres'].map { |g| g['name'] } if tmdb_data && tmdb_data['genres']
    genres += tvmaze_data['genres'] if tvmaze_data && tvmaze_data['genres']
    genres = genres.compact.uniq

    poster_path = nil
    if tmdb_data && tmdb_data['poster_path']
      poster_path = "https://image.tmdb.org/t/p/w500#{tmdb_data['poster_path']}"
    elsif tvmaze_data && tvmaze_data.dig('image', 'medium')
      poster_path = tvmaze_data.dig('image', 'medium')
    end

    overview = tmdb_data&.fetch('overview', nil)
    overview ||= tvmaze_data&.fetch('summary', nil)&.gsub(/<[^>]*>/, '') # TVMaze uses HTML

    {
      name:        tmdb_data&.fetch('name', nil) || tvmaze_data&.fetch('name', nil),
      runtime:     calculate_runtime(tmdb_data, tvmaze_data),
      genres:      genres,
      poster_path: poster_path,
      overview:    overview,
      external_ids: {
        tmdb_id:   tmdb_data&.fetch('id', nil),
        tvmaze_id: tvmaze_data&.fetch('id', nil)
      }
    }
  end

  def calculate_runtime(tmdb_data, tvmaze_data)
    # TMDB has episode_run_time as an array.
    # TVMaze has runtime (average per episode) and averageRuntime.
    
    rt = nil
    if tmdb_data && tmdb_data['episode_run_time']&.any?
      rt = tmdb_data['episode_run_time'].first
    end
    
    rt ||= tvmaze_data&.fetch('averageRuntime', nil) || tvmaze_data&.fetch('runtime', nil)
    
    rt ? "#{rt} minutes" : "unknown"
  end
end
