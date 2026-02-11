require 'json'
require 'sequel'

db_url = ENV['DATABASE_URL'] || (ENV['RACK_ENV'] == 'test' ? 'sqlite://data/test.db' : 'sqlite://data/silo_night.db')
Sequel.connect(db_url)

class Show < Sequel::Model

  many_to_many :users

  def average_runtime

    # split the strings by space and hyphen
    times = @values[:runtime].split(/\W/)

    # remove minutes
    times.delete("minutes")

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
      @list.append(
        Show.new(name:        show["name"],
                 wiki_page:   show["wiki_page"],
                 page_title:  show["page_title"],
                 runtime:     show["runtime"],
                 uri_encoded: show["uri_encoded"])
      )
    end
    return true
  end

end
