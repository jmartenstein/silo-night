require 'json'
require 'database'
require_relative 'show_metadata'

class Show < Sequel::Model

  many_to_many :users
  one_to_one :metadata, class: :ShowMetadata, key: :show_id

  def runtime=(value)
    raise "Deprecated Write Detected: Attempted to write to legacy 'runtime' column."
  end

  def poster_path=(value)
    raise "Deprecated Write Detected: Attempted to write to legacy 'poster_path' column."
  end

  def runtime
    if metadata && metadata.payload && metadata.payload['runtime']
      metadata.payload['runtime']
    else
      @values[:deprecated_runtime]
    end
  end

  def poster_path
    if metadata && metadata.payload && metadata.payload['poster_path']
      metadata.payload['poster_path']
    else
      @values[:deprecated_poster_path]
    end
  end

  def average_runtime

    # split the strings by non-word characters
    times = self.runtime.to_s.split(/\W+/)

    # remove common words
    times.delete("minutes")
    times.delete("min")
    times.delete("")

    # If nothing is left, return 0 or some default
    return 30 if times.empty?

    # sum the remaining values:
    sum = times.map(&:to_i).reduce(:+)

    return sum / times.count()

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
    j.each do |show|
      # Extract metadata fields
      metadata_payload = {
        "runtime" => show["runtime"],
        "poster_path" => show["poster_path"]
      }
      
      show_obj = Show.create(
        name:        show["name"],
        uri_encoded: show["uri_encoded"]
      )
      
      ShowMetadata.create(
        provider_name: 'json_import',
        external_id: show["name"].parameterize,
        payload: metadata_payload,
        show_id: show_obj.id
      )
      
      @list.append(show_obj)
    end
    return true
  end

end
