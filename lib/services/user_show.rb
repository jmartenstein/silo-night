module Services

  class UserShow
    def self.add_show(user, show)
      user.reload
    
      return if user.shows.include?(show)

      begin
        if user.add_show(show)
          user.generate_schedule
        end
      rescue Sequel::UniqueConstraintViolation
        nil
      end
    end
  end

end
