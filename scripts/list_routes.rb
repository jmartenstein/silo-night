require 'silo_night'

Sinatra::Application.routes.each do |k,v|
  v.each do |route|
    puts k + "," + route[0].to_s
  end
end

