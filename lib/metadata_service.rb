require_relative 'tmdb_adapter'
require_relative 'tvmaze_adapter'

class MetadataService
  TMDB_GENRE_MAP = {
    10759 => 'Action & Adventure',
    16 => 'Animation',
    35 => 'Comedy',
    80 => 'Crime',
    99 => 'Documentary',
    18 => 'Drama',
    10751 => 'Family',
    10762 => 'Kids',
    9648 => 'Mystery',
    10763 => 'News',
    10764 => 'Reality',
    10765 => 'Sci-Fi & Fantasy',
    10766 => 'Soap',
    10767 => 'Talk',
    10768 => 'War & Politics',
    37 => 'Western'
  }

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

  def search_shows(title)
    tmdb_results = @tmdb_adapter.search_shows_by_title(title)
    tvmaze_results = @tvmaze_adapter.search_shows_by_title(title)

    # Simple merging: use TVMaze as base because it has genre names in search results
    # and TMDB for additional name matching if needed.
    # For now, let's just return a unified list of suggestions.
    
    suggestions = []

    # Map TVMaze results
    tvmaze_results.each do |tvm|
      suggestions << {
        name: tvm['name'],
        year: extract_year(tvm['premiered']),
        genres: tvm['genres'] || [],
        poster_path: tvm.dig('image', 'medium')
      }
    end

    # Add TMDB results if they don't already exist (by name and year)
    tmdb_results.each do |tmdb|
      year = extract_year(tmdb['first_air_date'])
      unless suggestions.any? { |s| s[:name].downcase == tmdb['name'].downcase && s[:year] == year }
        genres = (tmdb['genre_ids'] || []).map { |id| TMDB_GENRE_MAP[id] }.compact
        poster_path = tmdb['poster_path'] ? "https://image.tmdb.org/t/p/w500#{tmdb['poster_path']}" : nil
        suggestions << {
          name: tmdb['name'],
          year: year,
          genres: genres,
          poster_path: poster_path
        }
      end
    end

    suggestions
  end

  private

  def extract_year(date_string)
    return nil if date_string.nil? || date_string.empty?
    date_string.split('-').first.to_i
  end

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

    year = extract_year(tmdb_data&.fetch('first_air_date', nil))
    year ||= extract_year(tvmaze_data&.fetch('premiered', nil))

    {
      name:        tmdb_data&.fetch('name', nil) || tvmaze_data&.fetch('name', nil),
      year:        year,
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
