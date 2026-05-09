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
require_relative 'support/vcr'

require 'sequel/extensions/migration'
require 'webmock/rspec'
require 'database_cleaner/sequel'
require 'dotenv'

Dotenv.load('.env.test')

FactoryBot.define do
  to_create { |instance| instance.save }
end

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  config.include Rack::Test::Methods

  # allow tags for unit tests
  config.define_derived_metadata(file_path: %r{spec/(services|lib)/}) do |metadata|
    metadata[:type] = :unit
  end

  # allow tags for integration tests
  config.define_derived_metadata(file_path: %r{spec/(integration|adapters|requests)/}) do |metadata|
    metadata[:type] = :integration
  end

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
