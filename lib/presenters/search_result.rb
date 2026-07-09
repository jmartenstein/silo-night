module Presenters
  class SearchResult
    def initialize(results)
      @results = results
    end

    def to_h
      @results.map do |r|
        {
          'name' => r[:name],
          'year' => r[:year],
          'genres' => r[:genres],
          'poster_path' => r[:poster_path],
          'runtime' => r[:runtime],
          'external_ids' => {
            'tmdb_id' => r.dig(:external_ids, :tmdb_id),
            'tvmaze_id' => r.dig(:external_ids, :tvmaze_id)
          }
        }
      end
    end

    def to_json(*_args)
      to_h.to_json
    end
  end
end
