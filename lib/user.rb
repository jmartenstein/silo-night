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
  end

  def generate_schedule()
    @shows.each do |show|
    end
    @schedule = {}
  end

end
