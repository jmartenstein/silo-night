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
          'poster_path' => r[:poster_path]
        }
      end
    end

    def to_json(*_args)
      to_h.to_json
    end
  end
end
