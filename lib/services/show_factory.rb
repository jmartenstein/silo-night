module Services
  class ShowFactory
    def self.create_with_metadata(name, metadata: nil)
      metadata_data = if metadata
                        # Client already fetched metadata — use it directly,
                        # normalising keys to symbols to match the MetadataService shape.
                        {
                          name:        metadata[:name] || name,
                          year:        metadata[:year],
                          genres:      metadata[:genres] || [],
                          poster_path: metadata[:poster_path],
                          runtime:     metadata[:runtime],
                          overview:    metadata[:overview],
                          external_ids: {
                            tmdb_id:   metadata.dig(:external_ids, :tmdb_id),
                            tvmaze_id: metadata.dig(:external_ids, :tvmaze_id)
                          }
                        }
                      else
                        MetadataService.new.get_show_metadata(name)
                      end

      return nil unless metadata_data

      final_name = metadata_data[:name]
      if ::Show.find(name: final_name)
        year = metadata_data[:year]
        if year
          final_name = "#{final_name} (#{year})"
          metadata_data[:name] = final_name
        end
      end

      provider = metadata ? 'client' : 'tmdb'
      external_id = metadata_data.dig(:external_ids, :tmdb_id)&.to_s ||
                    metadata_data[:name].downcase.gsub(/\s+/, '-')

      DB.transaction do
        show = ::Show.create(
          name: final_name,
          uri_encoded: URI.encode_www_form_component(final_name.downcase)
        )

        ::ShowMetadata.create(
          provider_name: provider,
          external_id:   external_id,
          payload:       metadata_data,
          show_id:       show.id
        )
        show
      end
    end
  end
end

