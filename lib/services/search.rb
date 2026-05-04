module Services
  class Search
    def self.search(query)
      MetadataService.new.search_shows(query)
    end
  end
end
