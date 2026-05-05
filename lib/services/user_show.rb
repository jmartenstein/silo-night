module Services
  class UserShow
    def self.add_show(user, show_or_name)
      user.reload
      show = if show_or_name.is_a?(::Show)
               show_or_name
             else
               ::Show.find(name: show_or_name) || create_show_from_metadata(show_or_name)
             end

      return false unless show
      return true if user.shows.include?(show)
      
      begin
        user.add_show(show)
        user.generate_schedule
        user.reload
        true
      rescue Sequel::UniqueConstraintViolation
        # Show is already added, just ensure schedule is consistent
        user.generate_schedule
        true
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

    private

    def self.create_show_from_metadata(name)
      metadata = MetadataService.new.get_show_metadata(name)
      return nil unless metadata

      ::Show.create(
        name: metadata[:name],
        runtime: metadata[:runtime],
        uri_encoded: URI.encode_www_form_component(metadata[:name].downcase),
        poster_path: metadata[:poster_path]
      )
    end
  end
end
