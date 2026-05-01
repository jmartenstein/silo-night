require 'presenters/schedule'

module Services
  class Schedule
    def self.get_for_user(user)
      raw_schedule = user.schedule
      schedule_hash = raw_schedule.is_a?(String) ? JSON.parse(raw_schedule) : (raw_schedule || {})
      
      Presenters::Schedule.new(schedule_hash)
    end

    def self.generate_for_user(user)
      new_schedule = user.generate_schedule
      Presenters::Schedule.new(new_schedule)
    end
  end
end
