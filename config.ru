# config.ru 
# run with rackup
#
$LOAD_PATH.unshift File.expand_path('./lib', __dir__)

require './silo_night'

Slim::Engine.set_options pretty: true, sort_attrs: false
run Sinatra::Application
