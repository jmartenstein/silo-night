module Presenters
  class Tonight
    def initialize(schedule, day)
      @schedule = schedule
      @day = day
    end

    def to_h
      @schedule[@day] || []
    end
  end
end
