require 'json'
require 'database'

class Show < Sequel::Model

  many_to_many :users
  one_to_many :metadata, class: :ShowMetadata

  def internal_metadata
    @internal_metadata ||= metadata_dataset.first(provider_name: 'internal')
  end

  def average_runtime
    raw_runtime = internal_metadata&.payload&.fetch('runtime', nil)
    return 30 if raw_runtime.nil? || (raw_runtime.is_a?(String) && raw_runtime.empty?)

    # If already an integer, return it
    return raw_runtime.to_i if raw_runtime.is_a?(Integer)

    # Otherwise, parse string
    times = raw_runtime.split(/\W+/)
    times.delete("minutes")
    times.delete("min")
    times.delete("")

    return 30 if times.empty?
    sum = times.map(&:to_i).reduce(:+)
    sum / times.count
  end

  def poster_path
    internal_metadata&.payload&.fetch('poster_path', nil)
  end
end

class Shows
  include Enumerable

  attr_accessor :list

  def initialize()
    @list = []
  end

  def each( &block )
    @list.each &block
  end

  def [](index)
    @list[index] || "None"
  end

  def load_from_file( filename="" )
    text = File.read(filename)
    load_from_json(text)
    return true
  end

  def load_from_json( json="[]" )
    j = JSON.parse(json)
    j.each do |show_data|
      show = Show.create(name: show_data["name"], uri_encoded: show_data["uri_encoded"])
      
      ShowMetadata.upsert(
        show_id: show.id,
        provider_name: 'internal',
        external_id: show.uri_encoded || show.name.downcase.gsub(' ', '_'),
        payload: {
          runtime: show_data["runtime"],
          wiki_page: show_data["wiki_page"],
          page_title: show_data["page_title"],
          poster_path: show_data["poster_path"]
        }
      )
      
      @list.append(show)
    end
    return true
  end

end
