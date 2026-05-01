require 'presenters/show'
require 'show'

module Presenters
  class Schedule
    DAYS = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday].freeze

    def initialize(schedule_hash)
      @schedule = schedule_hash || {}
    end

    def to_h
      DAYS.each_with_object({}) do |day, memo|
        raw_shows = @schedule[day] || @schedule[day.to_sym] || []
        
        memo[day] = raw_shows.map do |show_data|
          # Look up the real show object by name
          show_name = show_data.is_a?(Hash) ? show_data['name'] : show_data
          show = ::Show.find(name: show_name)
          
          if show
            # Use the Show presenter for consistent formatting
            Presenters::Show.new(show).to_h
          else
            # Fallback for data we can't find
            show_data
          end
        end
      end
    end

    def tonight(day_name)
      to_h[day_name] || []
    end
  end
end
