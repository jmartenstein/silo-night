module Services
  class ShowFactory
    def self.create_with_metadata(name)
      metadata_data = MetadataService.new.get_show_metadata(name)
      return nil unless metadata_data

      DB.transaction do
        show = ::Show.create(
          name: metadata_data[:name],
          runtime: metadata_data[:runtime],
          uri_encoded: URI.encode_www_form_component(metadata_data[:name].downcase),
          poster_path: metadata_data[:poster_path]
        )

        ::ShowMetadata.create(
          provider_name: 'tmdb',
          external_id: metadata_data.dig(:external_ids, :tmdb_id).to_s,
          payload: metadata_data,
          show_id: show.id
        )
        show
      end
    end
  end
end
