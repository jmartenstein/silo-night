require 'json'

class Show

  attr_accessor :name
  attr_accessor :runtime

  def initialize( s={"name"=>"","runtime"=>""} )
    @name    = s["name"]
    @runtime = s["runtime"]
  end

  def average_runtime

    # split the strings by space and hyphen
    times = @runtime.split(/[\s-]/)

    # remove minutes
    times.delete("minutes")

    # sum the remaining values:
    sum = times.map(&:to_i).reduce(:+)

    return sum / times.count()

  end

  def save_to_sql()
    db = Sequel.connect('sqlite://data/silo_night.db')
    db[:shows].insert_ignore.insert(name: @name, runtime: @runtime)
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
    j.each { |show| @list.append(Show.new(show)) }
    return true
  end

end
