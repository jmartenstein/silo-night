module Services
  class UserShow
    def self.add_show(user, show)
      user.reload
      return if user.shows.include?(show)
      
      begin
        user.add_show(show)
        user.generate_schedule
      rescue Sequel::UniqueConstraintViolation
        # Show is already added, just ensure schedule is consistent
        user.generate_schedule
      end
    end

    def self.remove_show(user, show_name)
      show = user.shows_dataset.first(name: show_name)
      return false unless show
      user.remove_show(show)
      user.generate_schedule
      true
    end

    def self.reorder(user, show_name, position)
      show = user.shows_dataset.first(name: show_name)
      return false unless show
      user.set_show_order(show, position.to_i)
      user.generate_schedule
      true
    end
  end
end
