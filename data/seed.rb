$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'database'
require 'user'
require 'show'
require 'metadata_service'

scenario = ENV['SEED_SCENARIO'] || 'smoke'
scenario_file = File.join(File.dirname(__FILE__), 'scenarios', "#{scenario}.rb")

if File.exist?(scenario_file)
  puts "Loading scenario: #{scenario}"
  load scenario_file
else
  puts "Scenario not found: #{scenario}"
  exit 1
end
