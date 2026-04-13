module Presenters
  class ShowPresenter
    def initialize(show)
      @show = show
    end

    def to_h
      {
        id: @show.id,
        name: @show.name,
        runtime: runtime_as_integer,
        uri_safe_name: @show.uri_encoded,
        poster_url: formatted_poster_url
      }
    end

    private

    def runtime_as_integer
      @show.runtime.to_i
    end

    def formatted_poster_url
      return nil unless @show.poster_path

      if @show.poster_path.start_with?('/')
        "https://image.tmdb.org/t/p/w500#{@show.poster_path}"
      else
        @show.poster_path
      end
    end
  end
end
