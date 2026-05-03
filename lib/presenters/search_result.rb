module Presenters
  class SearchResult
    def initialize(results)
      @results = results
    end

    def to_h
      @results.map { |r| { 'name' => r['title'] } }
    end

    def to_json(*_args)
      to_h.to_json
    end
  end
end
