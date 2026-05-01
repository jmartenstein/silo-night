module Presenters
  class Schedule
    DAYS = %w[Monday Tuesday Wednesday Thursday Friday Saturday Sunday].freeze

    def initialize(schedule_hash)
      @schedule = schedule_hash || {}
    end

    def to_h
      DAYS.each_with_object({}) do |day, memo|
        memo[day] = @schedule[day] || @schedule[day.to_sym] || []
      end
    end

    def tonight(day_name)
      to_h[day_name] || []
    end
  end
end
