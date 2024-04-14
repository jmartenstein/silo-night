class User

  attr_accessor :config
  attr_accessor :shows
  attr_accessor :schedule

  def initialize( u={"config"=>{},"shows"=>[],"schedule"=>{}} )
    @config   = u["config"]
    @shows    = u["shows"]
    @schedule = u["schedule"]
  end

end
