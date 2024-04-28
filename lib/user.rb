require 'show'

class User

  attr_accessor :config
  attr_accessor :shows
  attr_accessor :schedule

  def initialize( u={"config"=>{},"shows"=>[],"schedule"=>{}} )
    @config   = u["config"]
    @schedule = u["schedule"]
    @shows    = u["shows"]
  end

  def expand_shows()

    # create a lookup from the test data
    lookup = Shows.new()
    lookup.load_from_file("spec/support/shows.json")
    temp = []

    # build a temporary list of shows from the lookup
    @shows.each { |show| temp.append( lookup.find { |k,v| v = show } ) }
    @shows = temp

  end

  def generate_schedule()
    @schedule = { "monday" => ["foo"], "tuesday" => ["bar"] }
  end

end
