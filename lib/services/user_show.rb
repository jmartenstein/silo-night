module Services

  class UserShow
    def self.add_show(user, show)
    
      # guard clause: don't add if show is already present
      return if user.shows.include?(show)

      # if show isn't already present, then add it
      if user.add_show(show)
        user.generate_schedule
      end

    end
  end

end
