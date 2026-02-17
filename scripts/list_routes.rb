$LOAD_PATH.unshift(File.expand_path('..', __dir__))
$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'silo_night'

Sinatra::Application.routes.each do |k,v|
  v.each do |route|
    puts k + "," + route[0].to_s
  end
end

