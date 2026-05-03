require 'cgi'
# Fallback for older CGI/VCR compatibility issues
unless CGI.respond_to?(:parse)
  def CGI.parse(query)
    params = {}
    query.split(/[&;]/).each do |pairs|
      key, value = pairs.split('=', 2).map { |v| CGI.unescape(v) }
      if params.has_key?(key)
        params[key] << value
      else
        params[key] = [value]
      end
    end
    params
  end
end
ENV['RACK_ENV'] = 'test'
$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift File.expand_path('..', __dir__)

require 'database'
require 'factory_bot'
require 'rack/test'
require_relative '../silo_night'
require 'sequel/extensions/migration'
require 'webmock/rspec'
require 'vcr'
require 'database_cleaner/sequel'

FactoryBot.define do
  to_create { |instance| instance.save }
end

VCR.configure do
 |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.filter_sensitive_data('<TMDB_API_KEY>') { ENV['TMDB_API_KEY'] }
  config.filter_sensitive_data('<TVMAZE_API_KEY>') { ENV['TVMAZE_API_KEY'] }
  config.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  config.before(:suite) do
    unless Sequel::Migrator.is_current?(DB, 'db/migrations')
      puts "Database migrations are not up to date. Run 'RACK_ENV=test rake db:migrate' first."
      exit 1
    end
    FactoryBot.find_definitions
    DatabaseCleaner[:sequel].db = DB
    DatabaseCleaner[:sequel].strategy = :transaction

    DB.run("PRAGMA foreign_keys = OFF")
    DatabaseCleaner[:sequel].clean_with(:truncation)
    DB.run("PRAGMA foreign_keys = ON")
  end

  config.around(:each) do |example|
    DatabaseCleaner[:sequel].cleaning do
      example.run
    end
  end
end
