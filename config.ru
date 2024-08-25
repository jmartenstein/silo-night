# config.ru 
# run with rackup
#
require './silo_night'

Slim::Engine.set_options pretty: true, sort_attrs: false
run Sinatra::Application
