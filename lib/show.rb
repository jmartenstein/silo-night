class Show

  attr_accessor :name
  attr_accessor :runtime

  def initialize( s={"name"=>"","runtime"=>""} )
    @name    = s["name"]
    @runtime = s["runtime"]
  end

  def average_runtime
    return 25
  end

end
