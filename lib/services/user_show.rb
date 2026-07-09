require_relative 'show_factory'

module Services
  class UserShow
    def self.add_show(user, show_or_name, metadata: nil)
      user.reload
      show = if show_or_name.is_a?(::Show)
               show_or_name
             else
               # Extract external IDs from metadata
               ext_ids = metadata ? (metadata[:external_ids] || metadata['external_ids']) : nil
               tmdb_id = ext_ids ? (ext_ids[:tmdb_id] || ext_ids['tmdb_id']) : nil
               tvmaze_id = ext_ids ? (ext_ids[:tvmaze_id] || ext_ids['tvmaze_id']) : nil

               # Try to find by external IDs first
               found_show = ::Show.find_by_external_ids(tmdb_id: tmdb_id, tvmaze_id: tvmaze_id)

               # If not found by external ID, look up by name
               if !found_show
                 by_name = ::Show.find(name: show_or_name)
                 if by_name
                   # Check if the show by name has different external IDs.
                   if ext_ids && by_name.metadata
                     payload = by_name.metadata.payload
                     db_ext_ids = payload ? (payload['external_ids'] || payload[:external_ids]) : nil
                     db_tmdb_id = db_ext_ids ? (db_ext_ids['tmdb_id'] || db_ext_ids[:tmdb_id]) : nil
                     db_tvmaze_id = db_ext_ids ? (db_ext_ids['tvmaze_id'] || db_ext_ids[:tvmaze_id]) : nil

                     is_mismatch = (tmdb_id && db_tmdb_id && tmdb_id.to_s != db_tmdb_id.to_s) ||
                                   (tvmaze_id && db_tvmaze_id && tvmaze_id.to_s != db_tvmaze_id.to_s)
                     
                     if !is_mismatch
                       found_show = by_name
                     end
                   else
                     found_show = by_name
                   end
                 end
               end

               found_show || create_show_from_metadata(show_or_name, metadata: metadata)
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

    def self.create_show_from_metadata(name, metadata: nil)
      Services::ShowFactory.create_with_metadata(name, metadata: metadata)
    end
  end
end

